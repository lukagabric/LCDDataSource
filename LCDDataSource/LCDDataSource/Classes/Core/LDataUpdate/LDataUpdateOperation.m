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
#import "ASIHTTPRequest+L.h"


@implementation LDataUpdateOperation


#pragma mark - Init


- (instancetype)initWithRequest:(ASIHTTPRequest *)request andParser:(id <LCDParserInterface>)parser
{
    self = [super init];
    if (self)
    {
        NSAssert(request && parser, @"Dependencies are mandatory");

        _request = request;
        _parser = parser;
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
        
        if (_request.error || ![self isResponseValidForRequest:_request])
        {
            [self finishOperationWithError:[NSError errorWithDomain:@"Invalid response" code:1 userInfo:@{@"request": _request}]];
            return;
        }
        
        if ([self isCancelled]) return;
        
        NSError *parsingError;
        
        if ([self isDataNewForRequest:_request])
            parsingError = [self parseData];
        
        if ([self isCancelled]) return;
        
        [self finishOperationWithError:parsingError];
    }
}


#pragma mark - Parse data


- (NSError *)parseData
{
    __weak LDataUpdateOperation *weakSelf = self;
    __weak ASIHTTPRequest *weakRequest = _request;
    __weak NSManagedObjectContext *weakContext = _workerContext;
    __weak id <LCDParserInterface> weakParser = _parser;
    __block NSError *error;
    
    [_workerContext performBlockAndWait:^{
        [weakParser setContext:weakContext];
        [weakParser parseData:weakRequest.responseData];
        
        error = [weakParser error];
        
        if (error)
            [weakContext reset];
        else
            [weakSelf deleteOrphanedObjectsWithParser:weakParser];
    }];
    
    return error;
}


- (void)deleteOrphanedObjectsWithParser:(id <LCDParserInterface>)parser
{
    NSSet *items = [parser itemsSet];
    
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


- (BOOL)isDataNewForRequest:(ASIHTTPRequest *)request
{
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    NSAssert(key, @"Request needs to have a key for caching.");
    
    NSString *previousID = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSString *currentID = [request requestEtagOrLastModified];
    
    BOOL isDataNew = !previousID || !currentID || ![previousID isEqualToString:currentID];
    
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
    
    return isDataNew;
}


- (BOOL)isResponseValidForRequest:(ASIHTTPRequest *)request
{
    return YES;
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
            [_parser abortParsing];
        }
    }
}


#pragma mark -


@end
