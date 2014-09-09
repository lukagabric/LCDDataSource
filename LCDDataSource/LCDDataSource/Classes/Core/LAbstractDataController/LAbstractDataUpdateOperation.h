//
//  LAbstractDataUpdateOperation.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "ASIHTTPRequest.h"
#import "LCDParserInterface.h"
#import "LAbstractStackedRequestsSource.h"
#import "LDataUpdateOperationDelegate.h"


@interface LAbstractDataUpdateOperation : NSOperation


@property (weak, nonatomic, readonly) id <LDataUpdateOperationDelegate> dataUpdateDelegate;
@property (strong, nonatomic, readonly) NSManagedObjectContext *workerContext;
@property (strong, nonatomic, readonly) ASIHTTPRequest *request;


- (instancetype)initWithDataUpdateDelegate:(id <LDataUpdateOperationDelegate>)dataUpdateDelegate context:(NSManagedObjectContext *)context andRequest:(ASIHTTPRequest *)request;


@end


#pragma mark - Protected


@interface LAbstractDataUpdateOperation ()


- (NSError *)parseData;
- (void)parserDidFinish:(id <LCDParserInterface>)parser;
- (void)deleteItemsNotInSet:(NSSet *)items;


@end