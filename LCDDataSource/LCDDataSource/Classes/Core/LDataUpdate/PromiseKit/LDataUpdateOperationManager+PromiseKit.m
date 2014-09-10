//
//  LDataUpdateOperationManager+PromiseKit.m
//  LCDDataSource
//
//  Created by Luka Gabric on 10/09/14.
//
//


#import "LDataUpdateOperationManager+PromiseKit.h"


@implementation LDataUpdateOperationManager (PromiseKit)


- (PMKPromise *)dataUpdatePromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self updateDataWithCompletionBlock:^(NSError *error, BOOL newData) {
            if (error)
                reject(error);
            else
                fulfill(@(newData));
        }];
    }];
    
    return promise;
}


- (PMKPromise *)dataUpdateIgnoringCacheIntervalPromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self updateDataIgnoringCacheIntervalWithCompletionBlock:^(NSError *error, BOOL newData) {
            if (error)
                reject(error);
            else
                fulfill(parsedItems);
        }];
    }];
    
    return promise;
}


@end
