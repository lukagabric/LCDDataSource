//
//  LDataUpdateOperationDelegate.h
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//

#ifndef LCDDataSource_LDataUpdateOperationDelegate_h
#define LCDDataSource_LDataUpdateOperationDelegate_h


@class LDataUpdateOperation;
@protocol LCDParserInterface;


@protocol LDataUpdateOperationDelegate <NSObject>


- (void)operation:(LDataUpdateOperation *)operation didFinishWithError:(NSError *)error;


@end


#endif
