//
//  LAbstractDataUpdateOperation.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "LCDParserInterface.h"
#import "LGDataUpdateOperationManager.h"
#import "LDataUpdateOperationDelegate.h"


@interface LGDataUpdateOperation : NSOperation


- (instancetype)initWithSession:(NSURLSession *)session
                        request:(NSURLRequest *)request
              requestIdentifier:(NSString *)requestIdentifier
                      andParser:(id <LGCDParserInterface>)parser;

@property (weak, nonatomic) id <LGDataUpdateOperationDelegate> dataUpdateDelegate;
@property (strong, nonatomic) NSManagedObjectContext *workerContext;
@property (readonly, nonatomic) NSURLSessionDataTask *task;
@property (readonly, nonatomic) id <LGCDParserInterface> parser;
@property (readonly, nonatomic) NSURLResponse *response;
@property (readonly, nonatomic) NSData *responseData;
@property (readonly, nonatomic) NSString *responseFingerprint;
@property (readonly, nonatomic) NSError *error;
@property (readonly, nonatomic) NSString *requestIdentifier;


@end


#pragma mark - Protected


@interface LGDataUpdateOperation ()


- (NSError *)parseData;
- (void)deleteOrphanedObjectsWithParser:(id <LGCDParserInterface>)parser;
- (BOOL)isDataNew;
- (BOOL)isResponseValid;
- (void)finishOperationWithError:(NSError *)error;


@end
