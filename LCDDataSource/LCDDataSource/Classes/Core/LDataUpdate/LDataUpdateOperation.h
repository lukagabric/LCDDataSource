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


- (instancetype)initWithDataUpdateDelegate:(id <LDataUpdateOperationDelegate>)dataUpdateDelegate
                                   request:(ASIHTTPRequest *)request
                                   context:(NSManagedObjectContext *)context;


@property (readonly, nonatomic) id <LDataUpdateOperationDelegate> dataUpdateDelegate;
@property (readonly, nonatomic) NSManagedObjectContext *workerContext;
@property (readonly, nonatomic) ASIHTTPRequest *request;


@end
