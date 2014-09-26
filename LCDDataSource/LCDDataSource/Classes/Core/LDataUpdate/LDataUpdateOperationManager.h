//
//  LAbstractStackedRequestsSource.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "ASIHTTPRequest.h"
#import "LDataUpdateOperationDelegate.h"
#import "LDataUpdateOperation.h"


@interface LDataUpdateOperationManager : NSObject <LDataUpdateOperationDelegate>


@property (readonly, atomic) BOOL finished;
@property (readonly, atomic) BOOL running;
@property (readonly, atomic) BOOL canceled;
@property (readonly, atomic) BOOL newData;
@property (readonly, atomic) NSError *error;

@property (readonly, nonatomic) NSString *groupId;

@property (assign, nonatomic) BOOL saveAfterLoad;
@property (weak, nonatomic) UIView *activityView;


- (instancetype)initWithUpdateOperations:(NSArray *)updateOperations andGroupId:(NSString *)groupId;

- (void)updateDataIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)updateDataWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)cancelLoad;


@end


#pragma mark - Protected


@interface LDataUpdateOperationManager ()


@property (copy, nonatomic) void(^updateCompletionBlock)(NSError *error, BOOL newData);
@property (strong, nonatomic) NSManagedObjectContext *workerContext;
@property (strong, nonatomic) NSArray *updateOperations;
@property (assign, nonatomic) NSUInteger stackedRequestsSecondsToCache;


- (void)createWorkerContext;
- (void)freeWorkerContext;
- (void)performSave;


+ (ASIHTTPRequest *)stackedRequestWithUrl:(NSString *)url
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                  headers:(NSDictionary *)headers
                               parameters:(NSDictionary *)params
                            requestMethod:(NSString *)requestMethod
                                      key:(NSString *)key;

+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                          userInfo:(NSDictionary *)userInfo;


@end
