//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "NSManagedObjectContext+L.h"
#import "LCoreDataController.h"


@implementation NSManagedObjectContext (L)


- (void)saveContext
{
    [self saveContextAsync:YES withCompletionBlock:nil];
}


- (void)saveContextSync
{
    [self saveContextAsync:NO withCompletionBlock:nil];
}


- (void)saveContextAsync:(BOOL)async
{
    [self saveContextAsync:async withCompletionBlock:nil];
}


- (void)saveContextWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self saveContextAsync:YES withCompletionBlock:completionBlock];
}


- (void)saveContextAsync:(BOOL)async withCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self saveContextAsync:async saveParent:YES withCompletionBlock:completionBlock];
}


- (void)saveContextAsync:(BOOL)async saveParent:(BOOL)saveParent withCompletionBlock:(void(^)(NSError *error))completionBlock
{
    __weak NSManagedObjectContext *weakSelf = self;
    
    void(^saveBlock)(void) = ^{
        __block NSError *error = nil;
        
        [weakSelf performBlockAndWait:^{
            if ([weakSelf hasChanges])
            {
                NSString *contextName;
                
                if (weakSelf == rootMOC()) contextName = @"ROOT";
                else if (weakSelf == mainMOC()) contextName = @"MAIN";
                else contextName = @"WORKER";
                
                NSLog(@"%@ MOC WILL SAVE!", contextName);

                if (![weakSelf save:&error])
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
                    abort();
#endif
                }
                
                NSLog(@"%@ MOC DID SAVE!", contextName);
            }
        }];
        
        if (saveParent && [weakSelf parentContext])
            [[weakSelf parentContext] saveContextAsync:YES saveParent:YES withCompletionBlock:completionBlock];
        else if (completionBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };
    
    if (async)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), saveBlock);
    else
        saveBlock();
}


@end