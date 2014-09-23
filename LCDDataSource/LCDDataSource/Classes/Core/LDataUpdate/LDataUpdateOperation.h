//
//  LAbstractDataUpdateOperation.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "ASIHTTPRequest.h"
#import "LCDParserInterface.h"
#import "LDataUpdateOperationManager.h"
#import "LDataUpdateOperationDelegate.h"


@interface LDataUpdateOperation : NSOperation


- (instancetype)initWithRequest:(ASIHTTPRequest *)request andParser:(id <LCDParserInterface>)parser;

@property (weak, nonatomic) id <LDataUpdateOperationDelegate> dataUpdateDelegate;
@property (strong, nonatomic) NSManagedObjectContext *workerContext;
@property (readonly, nonatomic) ASIHTTPRequest *request;
@property (readonly, nonatomic) id <LCDParserInterface> parser;


@end


#pragma mark - Protected


@interface LDataUpdateOperation ()


- (NSError *)parseData;
- (void)deleteOrphanedObjectsWithParser:(id <LCDParserInterface>)parser;
- (BOOL)isDataNewForRequest:(ASIHTTPRequest *)request;
- (BOOL)isResponseValidForRequest:(ASIHTTPRequest *)request;
- (void)finishOperationWithError:(NSError *)error;


@end