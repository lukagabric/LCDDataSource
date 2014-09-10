//
//  LDataUpdateOperationManager+PromiseKit.h
//  LCDDataSource
//
//  Created by Luka Gabric on 10/09/14.
//
//


#import "LDataUpdateOperationManager.h"
#import "PromiseKit.h"


@interface LDataUpdateOperationManager (PromiseKit)


- (PMKPromise *)dataUpdatePromise;
- (PMKPromise *)dataUpdateIgnoringCacheIntervalPromise;


@end
