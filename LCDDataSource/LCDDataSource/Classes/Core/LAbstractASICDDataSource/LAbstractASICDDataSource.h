//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "LCDParserInterface.h"


@interface LAbstractASICDDataSource : NSObject
{
    NSArray *_stackedRequests;
}


@property (nonatomic, strong) NSManagedObjectContext *dsContext;
@property (assign, nonatomic) BOOL saveAfterLoad;
@property (weak, nonatomic) UIView *activityView;


- (void)loadStackedRequestsWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)loadStackedRequestsIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)loadStackedRequestsIgnoringCacheInterval:(BOOL)ignoreCacheInterval withCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (BOOL)isStackedRequestsDataStale;
- (void)cancelLoad;


@end


#pragma mark - Protected


@interface LAbstractASICDDataSource ()


- (NSArray *)stackedRequests;
- (void)saveContextAndStackedRequestsIDsWithCompletionBlock:(void (^)(NSError *error, BOOL newData))completionBlock;

- (NSString *)IDForRequest:(ASIHTTPRequest *)request;
- (void)saveStackedRequestsIDs;
- (void)saveIDForRequest:(ASIHTTPRequest *)request;

- (void)saveStackedRequestsLoadTime;
- (NSUInteger)stackedRequestsLoadInterval;
- (BOOL)isDataNewForRequest:(ASIHTTPRequest *)request;

- (void)parserDidFinish:(id <LCDParserInterface>)parser;
- (void)deleteItemsNotInSet:(NSSet *)items;


@property (assign, nonatomic) BOOL stackedRequestsRunning;
@property (assign, nonatomic) BOOL loadCancelled;
@property (weak, nonatomic) ASIHTTPRequest *currentRequest;
@property (weak, nonatomic) id <LCDParserInterface> currentParser;


+ (ASIHTTPRequest *)stackedRequestWithUrl:(NSString *)url
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                  headers:(NSDictionary *)headers
                               parameters:(NSDictionary *)params
                            requestMethod:(NSString *)requestMethod
                                      key:(NSString *)key
                              parserClass:(Class)parserClass
                           parserUserInfo:(id)parserUserInfo;


+ (ASIHTTPRequest *)stackedRequestWithUrl:(NSString *)url
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                  headers:(NSDictionary *)headers
                               parameters:(NSDictionary *)params
                            requestMethod:(NSString *)requestMethod
                                      key:(NSString *)key
                              parserClass:(Class)parserClass;

+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                          userInfo:(NSDictionary *)userInfo;


@end