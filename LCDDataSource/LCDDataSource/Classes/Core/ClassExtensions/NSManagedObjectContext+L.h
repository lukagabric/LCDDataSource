//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <CoreData/CoreData.h>


@interface NSManagedObjectContext (L)


- (void)saveContext;
- (void)saveContextSync;
- (void)saveContextAsync:(BOOL)async;
- (void)saveContextWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)saveContextAsync:(BOOL)async withCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)saveContextAsync:(BOOL)async saveParent:(BOOL)saveParent withCompletionBlock:(void(^)(NSError *error))completionBlock;

- (NSSet *)getObjectsWithParentMOCObjects:(NSSet *)parentMOCObjects;


@end