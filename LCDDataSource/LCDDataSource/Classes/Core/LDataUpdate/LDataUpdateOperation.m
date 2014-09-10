//
//  LAbstractDataUpdateOperation.m
//  LCDDataSource
//
//  Created by Luka Gabric on 07/09/14.
//
//


#import "LDataUpdateOperation.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+L.h"
#import "LCoreDataController.h"


@implementation LDataUpdateOperation


#pragma mark - Init


- (instancetype)initWithDataUpdateDelegate:(id <LDataUpdateOperationDelegate>)dataUpdateDelegate
                                   request:(ASIHTTPRequest *)request
                                   context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self)
    {
        _dataUpdateDelegate = dataUpdateDelegate;
        _workerContext = context;
        _request = request;
    }
    return self;
}


- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}


#pragma mark - Main


- (void)main
{
    @autoreleasepool
    {
        if ([self isCancelled]) return;
        
        [_request startSynchronous];

        if ([self isCancelled]) return;

        if (_request.error || ![_dataUpdateDelegate operation:self isResponseValidForRequest:_request])
        {
            [self finishOperationWithError:[NSError errorWithDomain:@"Invalid response" code:1 userInfo:@{@"request": _request}]];
            return;
        }
        
        if ([self isCancelled]) return;
        
        NSError *parsingError;
        
        if ([_dataUpdateDelegate operation:self isDataNewForRequest:_request])
            parsingError = [self parseData];
        
        if ([self isCancelled]) return;

        if (parsingError)
        {
            [self finishOperationWithError:parsingError];
            return;
        }

        if ([self isCancelled]) return;

        [self finishOperationWithError:nil];
    }
}


#pragma mark - Parse data


- (NSError *)parseData
{
    __weak LDataUpdateOperation *weakSelf = self;
    __weak ASIHTTPRequest *weakRequest = _request;
    __weak NSManagedObjectContext *weakContext = _workerContext;
    __block NSError *error;
    
    [_workerContext performBlockAndWait:^{
        Class parserClass = [weakRequest.userInfo objectForKey:@"parserClass"];
        
        NSAssert(parserClass, @"Parser class must be set with the request");
        
        id <LCDParserInterface> parser = [[parserClass class] new];
        [parser setUserInfo:[weakRequest.userInfo objectForKey:@"parserUserInfo"]];
        [parser setASIHTTPRequest:weakRequest];
        [parser setContext:weakContext];
        [parser parseData:weakRequest.responseData];
        
        error = [parser getError];
        
        if (error)
            [weakContext reset];
        else
            [weakSelf parserDidFinish:parser];
    }];
    
    return error;
}


- (void)parserDidFinish:(id <LCDParserInterface>)parser
{
    [self deleteItemsNotInSet:[parser getItemsSet]];
}


- (void)deleteItemsNotInSet:(NSSet *)items
{
    NSString *entityName = [[[items anyObject] entity] name];
    
    if (!entityName || [entityName length] == 0) return;
    
    NSFetchRequest *centerRequest = [NSFetchRequest new];
    
    centerRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_workerContext];
    centerRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
    
    NSArray *allObjects = [_workerContext executeFetchRequest:centerRequest error:&error];
    
    if (error)
        return;
    
    if ([allObjects count] > 0)
    {
        NSMutableSet *setToDelete = [NSMutableSet setWithArray:allObjects];
        
        [setToDelete minusSet:items];
        
        for (NSManagedObject *managedObjectToDelete in setToDelete)
        {
            [_workerContext deleteObject:managedObjectToDelete];
            
            NSLog(@"deleted object - %@", managedObjectToDelete);
        }
    }
}


#pragma mark - Finish


- (void)finishOperationWithError:(NSError *)error
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_dataUpdateDelegate operation:self didFinishWithError:error];
    });
}


#pragma mark - Cancel


- (void)cancel
{
    @synchronized(self)
    {
        if (![self isFinished])
        {
            [super cancel];
            [_request clearDelegatesAndCancel];
        }
    }
}


#pragma mark -


@end
