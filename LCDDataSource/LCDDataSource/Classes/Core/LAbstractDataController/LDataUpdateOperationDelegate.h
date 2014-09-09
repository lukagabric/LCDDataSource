//
//  LDataUpdateOperationDelegate.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//

#ifndef LCDDataSource_LDataUpdateOperationDelegate_h
#define LCDDataSource_LDataUpdateOperationDelegate_h


@class LAbstractDataUpdateOperation;


@protocol LDataUpdateOperationDelegate <NSObject>


- (BOOL)isDataNewForRequest:(ASIHTTPRequest *)request;
- (BOOL)isResponseValidForRequest:(ASIHTTPRequest *)request;
- (void)dataUpdateOperation:(LAbstractDataUpdateOperation *)operation didFinishWithError:(NSError *)error;


@end


#endif
