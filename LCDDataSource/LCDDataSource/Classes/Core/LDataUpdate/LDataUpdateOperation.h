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


@property (weak, nonatomic, readonly) id <LDataUpdateOperationDelegate> dataUpdateDelegate;
@property (nonatomic, readonly) NSManagedObjectContext *workerContext;
@property (nonatomic, readonly) ASIHTTPRequest *request;


- (instancetype)initWithDataUpdateDelegate:(id <LDataUpdateOperationDelegate>)dataUpdateDelegate
                                   request:(ASIHTTPRequest *)request
                                   context:(NSManagedObjectContext *)context;


@end


#pragma mark - Protected


@interface LDataUpdateOperation ()


- (NSError *)parseData;
- (void)parserDidFinish:(id <LCDParserInterface>)parser;
- (void)deleteItemsNotInSet:(NSSet *)items;


@end