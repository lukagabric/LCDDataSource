//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "NSManagedObject+L.h"
#import "LCoreDataController.h"


@implementation NSManagedObject (L)


#pragma mark - Factory


+ (id)newManagedObjectInContext:(NSManagedObjectContext *)context
{
	id managedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];

	return managedObject;
}


+ (id)newManagedObject
{
	id managedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:mainMOC()];

	return managedObject;
}


#pragma mark - Get item(s)


+ (id)getItemWithKey:(NSString *)key andValue:(id)value
{
    return [self getItemWithKey:key andValue:value usingContext:mainMOC()];
}


+ (id)getItemWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value] usingContext:ctx];
}


+ (id)getItemWithPredicate:(NSPredicate *)predicate
{
    return [self getItemWithPredicate:predicate usingContext:mainMOC()];
}


+ (id)getItemWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:ctx]];
    [fetchRequest setFetchLimit:1];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
    
    if (error || [fetchedObjects count] == 0)
        return nil;
    
    return [fetchedObjects objectAtIndex:0];
}


+ (NSArray *)getAllItems
{
    return [self getItemsWithPredicate:nil];
}


+ (NSArray *)getAllItemsUsingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithPredicate:nil andSortDescriptors:nil usingContext:ctx];
}


+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value sortedBy:(NSString *)sortKey ascending:(BOOL)ascending
{
    return [self getItemsWithKey:key andValue:value sortedBy:sortKey ascending:ascending usingContext:mainMOC()];
}


+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value sortedBy:(NSString *)sortKey ascending:(BOOL)ascending usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value] andSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending]] usingContext:ctx];
}


+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value
{
    return [self getItemsWithKey:key andValue:value usingContext:mainMOC()];
}


+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value] usingContext:ctx];
}


+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate
{
    return [self getItemsWithPredicate:predicate usingContext:mainMOC()];
}


+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithPredicate:predicate andSortDescriptors:nil usingContext:ctx];
}


+ (NSArray *)getItemsSortedByKey:(NSString *)key
{
    return [self getItemsSortedByKey:key ascending:YES usingContext:mainMOC()];
}


+ (NSArray *)getItemsSortedByKey:(NSString *)key ascending:(BOOL)ascending
{
    return [self getItemsSortedByKey:key ascending:ascending usingContext:mainMOC()];
}


+ (NSArray *)getItemsSortedByKey:(NSString *)key ascending:(BOOL)ascending usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:key ascending:ascending]] usingContext:ctx];
}


+ (NSArray *)getItemsWithSortDescriptors:(NSArray *)sortDescriptors
{
    return [self getItemsWithSortDescriptors:sortDescriptors usingContext:mainMOC()];
}


+ (NSArray *)getItemsWithSortDescriptors:(NSArray *)sortDescriptors usingContext:(NSManagedObjectContext *)ctx
{
    return [self getItemsWithPredicate:nil andSortDescriptors:sortDescriptors usingContext:ctx];
}


+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors
{
    return [self getItemsWithPredicate:predicate andSortDescriptors:sortDescriptors usingContext:mainMOC()];
}


+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors usingContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:ctx]];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    if (sortDescriptors)
        [fetchRequest setSortDescriptors:sortDescriptors];
        
    NSError *error = nil;
    
    NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
    
    if (error || [fetchedObjects count] == 0)
        return nil;
    
    return fetchedObjects;
}


#pragma mark - Get count


+ (NSUInteger)getCount
{
    return [self getCountWithPredicate:nil usingContext:mainMOC()];
}


+ (NSUInteger)getCountWithKey:(NSString *)key andValue:(id)value
{
    return [self getCountWithKey:key andValue:value usingContext:mainMOC()];
}


+ (NSUInteger)getCountWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx
{
    return [self getCountWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value] usingContext:ctx];
}


+ (NSUInteger)getCountWithPredicate:(NSPredicate *)predicate
{
    return [self getCountWithPredicate:predicate usingContext:mainMOC()];
}


+ (NSUInteger)getCountWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:ctx]];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    return [ctx countForFetchRequest:fetchRequest error:&error];
}


#pragma mark - delete


+ (void)deleteAllItems
{
    [self deleteAllItemsUsingContext:mainMOC()];
}


+ (void)deleteAllItemsUsingContext:(NSManagedObjectContext *)ctx
{
    [self deleteItemsWithPredicate:nil usingContext:ctx];
}


+ (void)deleteItemsWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:ctx]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
    
    if (!error && [fetchedObjects count] > 0)
    {
        for (NSManagedObject *object in fetchedObjects)
            [ctx deleteObject:object];
    }
    
    [ctx saveContext];
}


#pragma mark -


@end