//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractASICDDataSource.h"
#import "LCoreDataController.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+L.h"


#pragma mark - DSAssert


#if DEBUG
#define DSAssert(condition, desc, ...)	\
do {				\
__PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
if (!(condition)) {		\
[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
object:self file:[NSString stringWithUTF8String:__FILE__] \
lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
}				\
__PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
} while(0)
#else
#define DSAssert(condition, desc, ...)
#endif


#pragma mark -


@implementation LAbstractASICDDataSource


#pragma mark - Synthesize


@synthesize dsContext = _dsContext;


#pragma mark - Init & dealloc


- (id)init
{
	self = [super init];
	if (self)
	{
        [self initialize];
	}
	return self;
}


- (void)initialize
{
    [self createDSContext];
    _saveAfterLoad = YES;
}


- (void)dealloc
{
    [self cancelLoad];
    [self freeDSContext];
}


#pragma mark - Data source context


- (void)createDSContext
{
    [self freeDSContext];
    
    _dsContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_dsContext setParentContext:mainMOC()];
}


- (void)freeDSContext
{
    if (_dsContext)
        [_dsContext reset];
    
    _dsContext = nil;
}


#pragma mark - Stacked requests getter


- (NSArray *)stackedRequests
{
    return nil;
}


#pragma mark - Load stacked requests


- (void)loadStackedRequestsWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self loadStackedRequestsIgnoringCacheInterval:NO withCompletionBlock:completionBlock];
}


- (void)loadStackedRequestsIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self loadStackedRequestsIgnoringCacheInterval:YES withCompletionBlock:completionBlock];
}


- (void)loadStackedRequestsIgnoringCacheInterval:(BOOL)ignoreCacheInterval withCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    DSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_stackedRequestsRunning == YES || [_stackedRequests = [self stackedRequests] count] == 0) return;
    
    _stackedRequestsRunning = YES;
    
    if ([self isStackedRequestsDataStale] || ignoreCacheInterval)
    {
        if (_activityView)
            [self showProgressForActivityView];
        
        [self loadStackedRequest:[_stackedRequests objectAtIndex:0] withCompletionBlock:completionBlock];
    }
    else
    {
        if (completionBlock && !_loadCancelled)
            completionBlock(nil, NO);
    }
}


- (void)loadStackedRequest:(ASIHTTPRequest *)request withCompletionBlock:(void (^)(NSError *error, BOOL newData))completionBlock
{
    DSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    DSAssert(request, @"Request must not be nil.");
    
    ASIHTTPRequest *nextRequest;
    NSUInteger currentRequestIndex = [_stackedRequests indexOfObject:request];
    
    if (currentRequestIndex + 1 < [_stackedRequests count])
        nextRequest = [_stackedRequests objectAtIndex:currentRequestIndex + 1];
    
    __weak typeof(self) weakSelf = self;
    __weak NSManagedObjectContext *weakContext = _dsContext;
    __weak UIView *weakActivityView = _activityView;
    
    void (^stackedRequestCompletion)(ASIHTTPRequest *, NSSet *, NSError *) = ^(ASIHTTPRequest *request, NSSet *parsedItems, NSError *error) {
        if (weakSelf.loadCancelled) return;
        
        if (error)
        {
            [weakContext reset];
            
            if (weakActivityView)
                [weakSelf hideProgressForActivityView];
            
            if (completionBlock && !weakSelf.loadCancelled)
                completionBlock(error, NO);
        }
        else
        {
            if (nextRequest)
            {
                [weakSelf loadStackedRequest:nextRequest withCompletionBlock:completionBlock];
            }
            else
            {
                if (weakSelf.saveAfterLoad)
                    [weakSelf saveContextAndStackedRequestsIDsWithCompletionBlock:completionBlock];
                else if (completionBlock && !weakSelf.loadCancelled)
                    completionBlock(nil, [weakContext hasChanges]);
            }
        }
    };
    
    [self getObjectsWithRequest:request
             andCompletionBlock:stackedRequestCompletion];
}


#pragma mark - Cancel Load


- (void)cancelLoad
{
    @synchronized(_currentRequest)
    {
        [_currentRequest clearDelegatesAndCancel];
    }
    
    @synchronized(_currentParser)
    {
        [_currentParser abortParsing];
    }
    
    _loadCancelled = YES;
}


#pragma mark - Get and parse data


- (void)getObjectsWithRequest:(ASIHTTPRequest *)request
           andCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSSet *parsedItems, NSError *error))completionBlock
{
	if (!request || !request.url)
	{
		completionBlock(request, nil, [NSError errorWithDomain:@"Incorrect request parameters, is url nil?" code:400 userInfo:nil]);
	}
	else
	{
		__weak LAbstractASICDDataSource *weakSelf = self;
		__weak ASIHTTPRequest *req = request;
        
		void (^reqCompletionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
            weakSelf.currentRequest = nil;
			[weakSelf parseDataFromRequest:asiHttpRequest withCompletionBlock:completionBlock];
		};
        
		[request setCompletionBlock:^{
            reqCompletionBlock(req);
        }];
        
		[request setFailedBlock:^{
            reqCompletionBlock(req);
        }];
        
        _currentRequest = request;
        
        [request startAsynchronous];
	}
}


- (void)parseDataFromRequest:(ASIHTTPRequest *)req
         withCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSSet *parsedItems, NSError *error))completionBlock
{
    __weak LAbstractASICDDataSource *weakSelf = self;
    __weak NSManagedObjectContext *weakContext = _dsContext;
    __block NSError *error = req.error;
    __block NSSet *parsedItems;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf.loadCancelled && !error && [weakSelf isDataNewForRequest:req])
        {
            [weakContext performBlockAndWait:^{
                Class parserClass = [req.userInfo objectForKey:@"parserClass"];
                
                DSAssert(parserClass, @"Parser class must be set with the request");

                id <LCDParserInterface> parser = [[parserClass class] new];
                weakSelf.currentParser = parser;
                [parser setUserInfo:[req.userInfo objectForKey:@"parserUserInfo"]];
                [parser setASIHTTPRequest:req];
                [parser setContext:weakContext];
                [parser parseData:req.responseData];
                weakSelf.currentParser = nil;
                
                error = [parser getError];
                
                if (error)
                {
                    [weakContext reset];
                    parsedItems = nil;
                }
                else
                {
                    [weakSelf parserDidFinish:parser];
                }
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(req, parsedItems, error);
        });
    });
}


#pragma mark - parsedItemsSet


- (void)parserDidFinish:(id <LCDParserInterface>)parser
{
    [self deleteItemsNotInSet:[parser getItemsSet]];
}


- (void)deleteItemsNotInSet:(NSSet *)items
{
    NSString *entityName = [[[items anyObject] entity] name];
    
    if (!entityName || [entityName length] == 0) return;
    
    NSFetchRequest *centerRequest = [NSFetchRequest new];
    
    centerRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_dsContext];
    centerRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
    
    NSArray *allObjects = [_dsContext executeFetchRequest:centerRequest error:&error];
    
    if (error)
        return;
    
    if ([allObjects count] > 0)
    {
        NSMutableSet *setToDelete = [NSMutableSet setWithArray:allObjects];
        
        [setToDelete minusSet:items];
        
        for (NSManagedObject *managedObjectToDelete in setToDelete)
        {
            [_dsContext deleteObject:managedObjectToDelete];
            
            NSLog(@"deleted object - %@", managedObjectToDelete);
        }
    }
}


#pragma mark - Save Context and Request IDs


- (void)saveContextAndStackedRequestsIDsWithCompletionBlock:(void (^)(NSError *error, BOOL newData))completionBlock
{
    DSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    __weak typeof(self) weakSelf = self;
    
    if ([_dsContext hasChanges])
    {
        __weak UIView *weakActivityView = _activityView;
        
        [_dsContext saveContextAsync:NO saveParent:NO withCompletionBlock:^(NSError *error) {
            if (completionBlock && !_loadCancelled)
                completionBlock(error, YES);
            
            if (weakActivityView)
                [weakSelf hideProgressForActivityView];
            
            [mainMOC() saveContextWithCompletionBlock:^(NSError *error) {
                [weakSelf saveStackedRequestsIDs];
                [weakSelf saveStackedRequestsLoadTime];
            }];
        }];
    }
    else
    {
        NSLog(@"No need to save because there are no changes in context.");
        
        [self saveStackedRequestsLoadTime];
        
        if (_activityView)
            [self hideProgressForActivityView];
        
        if (completionBlock && !_loadCancelled)
            completionBlock(nil, NO);
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


- (void)saveStackedRequestsIDs
{
    for (ASIHTTPRequest *request in _stackedRequests)
        [self saveIDForRequest:request];
}


- (void)saveIDForRequest:(ASIHTTPRequest *)request
{
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    DSAssert(key, @"Request needs to have a key for caching.");
    
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


- (void)saveStackedRequestsLoadTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"StackedRequestsLastLoadTime.%@", NSStringFromClass([self class])]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - isDataNewForRequest


- (BOOL)isDataNewForRequest:(ASIHTTPRequest *)request
{
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    DSAssert(key, @"Request needs to have a key for caching.");
    
    NSString *previousID = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSString *currentID = [self IDForRequest:request];
    
    BOOL isDataNew = !previousID || !currentID || ![previousID isEqualToString:currentID];
    
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
    
    return isDataNew;
}


#pragma mark - LoadInterval


- (NSUInteger)stackedRequestsLoadInterval
{
    return 900;
}


#pragma mark - isStackedRequestsDataStale


- (BOOL)isStackedRequestsDataStale
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"StackedRequestsLastLoadTime.%@", NSStringFromClass([self class])]];
    
    return !lastUpdate || [(NSDate *)[lastUpdate dateByAddingTimeInterval:[self stackedRequestsLoadInterval]] compare:[NSDate date]] != NSOrderedDescending;
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


#pragma mark - Create request


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
                 secondsToCache:0
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
                 secondsToCache:0
                        headers:headers
                     parameters:params
                  requestMethod:requestMethod
                       userInfo:@{@"key" : [NSString stringWithFormat:@"ASIHTTPRequest.key.%@", key], @"parserClass" : parserClass}];
}


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
				   timeoutInterval:(NSTimeInterval)timeoutInterval
					secondsToCache:(NSTimeInterval)secondsToCache
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
    
	__weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
	request.downloadCache = [ASIDownloadCache sharedCache];
    request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
	request.requestMethod = requestMethod;
	request.timeOutSeconds = timeoutInterval;
	request.secondsToCache = secondsToCache;
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