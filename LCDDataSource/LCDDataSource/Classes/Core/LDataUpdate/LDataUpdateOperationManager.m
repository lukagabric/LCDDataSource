//
//  LAbstractStackedRequestsSource.m
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "LDataUpdateOperationManager.h"
#import "ASIDownloadCache.h"
#import "LCoreDataController.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+L.h"
#import "MBProgressHUD.h"


#define kStackedRequestsLastUpdateTimeFormat @"StackedRequestsLastUpdateTime.%@"


@implementation LDataUpdateOperationManager


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


- (instancetype)initWithStackedRequests:(NSArray *)stackedRequests
{
	self = [super init];
	if (self)
	{
        _stackedRequests = [stackedRequests copy];
        [self initialize];
	}
	return self;
}


- (void)initialize
{
    [self createWorkerContext];
    _saveAfterLoad = YES;
    _stackedRequestsSecondsToCache = 900;
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
        if ([_stackedRequests count] == 0)
        {
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
            return;
        }
        
        NSMutableArray *operations = [NSMutableArray new];
        
        for (ASIHTTPRequest *request in _stackedRequests)
            [operations addObject:[self operationForRequest:request]];
        
        _operations = [operations copy];
        
        [dataUpdateQueue addOperations:_operations waitUntilFinished:NO];
    }
    else
    {
        NSDate *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, NSStringFromClass([self class])]];
        
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
    
    [self loadDidFinishWithError:nil canceled:YES forceNewData:NO];
    
    for (LDataUpdateOperation *operation in _operations)
        [operation cancel];
}


#pragma mark - LDataUpdateOperationDelegate


- (void)operation:(LDataUpdateOperation *)operation didFinishWithError:(NSError *)error
{
    if (_canceled) return;
    
    if (error)
    {
        [self loadDidFinishWithError:error canceled:NO forceNewData:NO];
    }
    else if (operation.request == [_stackedRequests lastObject])
    {
        if (_saveAfterLoad)
            [self performSave];
        else
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
    
    NSLog(@"- (void)operation:(LDataUpdateOperation *)operation didFinishWithError:(NSError *)error");
}


- (BOOL)operation:(LDataUpdateOperation *)operation isDataNewForRequest:(ASIHTTPRequest *)request
{
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    NSAssert(key, @"Request needs to have a key for caching.");
    
    NSString *previousID = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSString *currentID = [self IDForRequest:request];
    
    BOOL isDataNew = !previousID || !currentID || ![previousID isEqualToString:currentID];
    
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
    
    return isDataNew;
}


- (BOOL)operation:(LDataUpdateOperation *)operation isResponseValidForRequest:(ASIHTTPRequest *)request
{
    return YES;
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


- (LDataUpdateOperation *)operationForRequest:(ASIHTTPRequest *)request
{
    return [[LDataUpdateOperation alloc] initWithDataUpdateDelegate:self
                                                            request:request
                                                            context:_workerContext];
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


#pragma mark - Request ID convenience methods


- (void)saveStackedRequestsIDs
{
    for (ASIHTTPRequest *request in _stackedRequests)
        [self saveIDForRequest:request];
}


- (void)saveIDForRequest:(ASIHTTPRequest *)request
{
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    NSAssert(key, @"Request needs to have a key for caching.");
    
    NSString *reqId = [self IDForRequest:request];
    
    if (reqId)
    {
        [[NSUserDefaults standardUserDefaults] setObject:reqId forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Saved request ID: '%@' for request with key: '%@'", reqId, key);
    }
    else
    {
        NSLog(@"No ID for request with url: '%@'. Request needs to have ID (e.g. ETag or Last-Modified) for caching.", [request.url absoluteString]);
    }
    
}


- (NSString *)IDForRequest:(ASIHTTPRequest *)request
{
    NSDictionary *headers = request.responseHeaders;
    
    NSString *reqId = [headers objectForKey:@"Etag"];
    
    if (!reqId)
        reqId = [headers objectForKey:@"Last-Modified"];
    
    return reqId;
}


#pragma mark - Last update time


- (void)saveStackedRequestsLastUpdateTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, NSStringFromClass([self class])]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)isStackedRequestsDataStale
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, NSStringFromClass([self class])]];
    
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


#pragma mark - Request create convenience


+ (NSString *)queryStringFromParams:(NSDictionary *)dict
{
	if ([dict count] == 0)
	{
		return nil;
	}
    
	NSMutableString *query = [NSMutableString string];
    
	for (NSString *parameter in [dict allKeys])
	{
		[query appendFormat:@"&%@=%@", [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [[dict valueForKey:parameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
    
	return [NSString stringWithFormat:@"%@", [query substringFromIndex:1]];
}


+ (ASIHTTPRequest *)stackedRequestWithUrl:(NSString *)url
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                  headers:(NSDictionary *)headers
                               parameters:(NSDictionary *)params
                            requestMethod:(NSString *)requestMethod
                                      key:(NSString *)key
                              parserClass:(Class)parserClass
                           parserUserInfo:(id)parserUserInfo
{
    return [self requestWithUrl:url
                timeoutInterval:timeoutInterval
                        headers:headers
                     parameters:params
                  requestMethod:requestMethod
                       userInfo:@{@"key" : [NSString stringWithFormat:@"ASIHTTPRequest.key.%@", key], @"parserClass" : parserClass, @"parserUserInfo" : parserUserInfo}];
}


+ (ASIHTTPRequest *)stackedRequestWithUrl:(NSString *)url
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                  headers:(NSDictionary *)headers
                               parameters:(NSDictionary *)params
                            requestMethod:(NSString *)requestMethod
                                      key:(NSString *)key
                              parserClass:(Class)parserClass
{
    return [self requestWithUrl:url
                timeoutInterval:timeoutInterval
                        headers:headers
                     parameters:params
                  requestMethod:requestMethod
                       userInfo:@{@"key" : [NSString stringWithFormat:@"ASIHTTPRequest.key.%@", key], @"parserClass" : parserClass}];
}


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
				   timeoutInterval:(NSTimeInterval)timeoutInterval
						   headers:(NSDictionary *)headers
						parameters:(NSDictionary *)params
					 requestMethod:(NSString *)requestMethod
                          userInfo:(NSDictionary *)userInfo
{
	NSString *paramsString = [self queryStringFromParams:params];
	NSString *urlString = url;
    
	if ([requestMethod isEqualToString:@"GET"] && paramsString)
	{
		urlString = [url stringByAppendingFormat:@"?%@", paramsString];
	}
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
	request.downloadCache = [ASIDownloadCache sharedCache];
    request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
	request.requestMethod = requestMethod;
	request.timeOutSeconds = timeoutInterval;
	request.secondsToCache = 0;
    request.userInfo = userInfo;
    
	for (NSString *key in [headers allKeys])
	{
		[request addRequestHeader:key value:[headers valueForKey:key]];
	}
    
	if ([requestMethod isEqualToString:@"POST"] && paramsString)
	{
		[request setPostBody:[NSMutableData dataWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding]]];
		[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	}
    
	return request;
}


#pragma mark -


@end
