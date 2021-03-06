//
//  LAbstractStackedRequestsSource.m
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "LGDataUpdateOperationManager.h"
#import "LGCoreDataController.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+L.h"
#import "MBProgressHUD.h"


#define kStackedRequestsLastUpdateTimeFormat @"StackedRequestsLastUpdateTime.groupId.%@"


@implementation LGDataUpdateOperationManager


#pragma mark - Init & dealloc


static NSOperationQueue *dataUpdateQueue;


+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataUpdateQueue = [NSOperationQueue new];
        dataUpdateQueue.maxConcurrentOperationCount = 1;
        [dataUpdateQueue setSuspended:NO];
    });
}


- (instancetype)initWithUpdateOperations:(NSArray *)updateOperations andGroupId:(NSString *)groupId
{
	self = [super init];
	if (self)
	{
        _updateOperations = [updateOperations copy];
        _groupId = groupId;
        [self initialize];
	}
	return self;
}


- (void)initialize
{
    [self createWorkerContext];
    _saveAfterLoad = YES;
    _stackedRequestsSecondsToCache = 900;
    
    for (LGDataUpdateOperation *operation in _updateOperations)
    {
        operation.dataUpdateDelegate = self;
        operation.workerContext = _workerContext;
    }
}


- (void)dealloc
{
    [self freeWorkerContext];
    NSLog(@"%@ dealloc", [self class]);
}


#pragma mark - State methods


- (void)loadDidStart
{
    _finished = NO;
    _running = YES;
    _newData = NO;
    _canceled = NO;
    _error = nil;
}


- (void)loadDidFinishWithError:(NSError *)error canceled:(BOOL)canceled forceNewData:(BOOL)forceNewData
{
    _finished = YES;
    _running = NO;
    _canceled = canceled;
    _error = error;
    
    if (error || canceled)
        _newData = NO;
    else if (forceNewData)
        _newData = YES;
    else
        _newData = [_workerContext hasChanges];
    
    if (_updateCompletionBlock && !_canceled)
        _updateCompletionBlock(_error, _newData);
    
    if (_activityView)
        [self hideProgressForActivityView];
}


#pragma mark - Public methods


- (void)updateDataIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self updateDataIgnoringCacheInterval:YES withCompletionBlock:completionBlock];
}


- (void)updateDataWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self updateDataIgnoringCacheInterval:NO withCompletionBlock:completionBlock];
}


- (void)updateDataIgnoringCacheInterval:(BOOL)ignoreCacheInterval
                    withCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    NSAssert(!_running, @"Trying to start request that is already running");
    
    if (_running) return;
    
    _updateCompletionBlock = [completionBlock copy];
    
    [self loadDidStart];
    
    if ([self isStackedRequestsDataStale] || ignoreCacheInterval)
    {
        if (_activityView)
            [self showProgressForActivityView];
    ;
        if ([_updateOperations count] == 0)
        {
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
            return;
        }
        
        [dataUpdateQueue addOperations:_updateOperations waitUntilFinished:NO];
    }
    else
    {
        NSDate *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
        
        NSTimeInterval lastUpdateInterval = [lastUpdateDate timeIntervalSinceReferenceDate];
        NSTimeInterval staleAtInterval = lastUpdateInterval + _stackedRequestsSecondsToCache;
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval dataValidForInterval = staleAtInterval - currentTimeInterval;

        NSLog(@"Not updating because data is not stale. Stacked requests seconds to cache is set to %ld second(s). Last update was at %@ so data is valid for another %.0f second(s).", _stackedRequestsSecondsToCache, lastUpdateDate, dataValidForInterval);
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


- (void)cancelLoad
{
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(cancelLoad) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (_finished || _canceled) return;
    
    [self loadDidFinishWithError:nil canceled:YES forceNewData:NO];
    
    for (LGDataUpdateOperation *operation in _updateOperations)
        [operation cancel];
}


#pragma mark - LDataUpdateOperationDelegate


- (void)operation:(LGDataUpdateOperation *)operation didFinishWithError:(NSError *)error
{
    if (_canceled) return;
    
    if (error)
    {
        [self loadDidFinishWithError:error canceled:NO forceNewData:NO];
    }
    else if (operation == [_updateOperations lastObject])
    {
        if (_saveAfterLoad)
            [self performSave];
        else
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }    
}


#pragma mark - Protected methods


- (void)createWorkerContext
{
    [self freeWorkerContext];
    
    _workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_workerContext setParentContext:mainMOC()];
}


- (void)freeWorkerContext
{
    if (_workerContext)
        [_workerContext reset];
    
    _workerContext = nil;
}


#pragma mark - Save


- (void)performSave
{
    __weak typeof(self) weakSelf = self;
    
    if ([_workerContext hasChanges])
    {
        [_workerContext saveContextAsync:NO saveParent:NO withCompletionBlock:^(NSError *error) {
            if ([weakSelf canceled]) return;
            
            if (error) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadDidFinishWithError:nil canceled:NO forceNewData:YES];
            });
            
            [mainMOC() saveContextWithCompletionBlock:^(NSError *error) {
                NSAssert(error == nil, @"Error saving main moc");
                [weakSelf saveStackedRequestsIDs];
                [weakSelf saveStackedRequestsLastUpdateTime];
            }];
        }];
    }
    else
    {
        NSLog(@"No need to save because there are no changes in context.");
        
        [self saveStackedRequestsLastUpdateTime];
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


#pragma mark - saveStackedRequestsIDs


- (void)saveStackedRequestsIDs
{
    for (LGDataUpdateOperation *operation in _updateOperations)
    {
        NSString *requestIdentifier = operation.requestIdentifier;
        
        NSAssert(requestIdentifier, @"Request needs to have a key for caching.");
        
        NSString *responseFingerprint = operation.responseFingerprint;
        
        if (responseFingerprint)
        {
            [[NSUserDefaults standardUserDefaults] setObject:responseFingerprint forKey:requestIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"Saved response fingerprint: '%@' for request with identifier: '%@'", responseFingerprint, requestIdentifier);
        }
        else
        {
            NSLog(@"No response fingerprint for request with url: '%@' and identifier: '%@'. Request needs to have a fingerprint (e.g. ETag or Last-Modified) for caching.", [operation.response.URL absoluteString], requestIdentifier);
        }
    }
}


#pragma mark - Last update time


- (void)saveStackedRequestsLastUpdateTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)isStackedRequestsDataStale
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
    
    return !lastUpdate || [(NSDate *)[lastUpdate dateByAddingTimeInterval:_stackedRequestsSecondsToCache] compare:[NSDate date]] != NSOrderedDescending;
}


#pragma mark - Progress


- (void)showProgressForActivityView
{
    NSArray *huds = [MBProgressHUD allHUDsForView:_activityView];
    
    if (huds && [huds count] == 0)
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_activityView];
        hud.dimBackground = YES;
        [_activityView addSubview:hud];
        [hud show:YES];
    }
}


- (void)hideProgressForActivityView
{
    [MBProgressHUD hideAllHUDsForView:_activityView animated:YES];
}


#pragma mark -


@end
