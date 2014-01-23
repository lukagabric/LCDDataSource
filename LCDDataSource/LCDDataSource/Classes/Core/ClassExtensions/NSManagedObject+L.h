//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <CoreData/CoreData.h>


@interface NSManagedObject (L)


#pragma mark - Factory


+ (id)newManagedObjectInContext:(NSManagedObjectContext *)context;
+ (id)newManagedObject;


#pragma mark - Get item(s)


+ (id)getItemWithKey:(NSString *)key andValue:(id)value;
+ (id)getItemWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx;

+ (id)getItemWithPredicate:(NSPredicate *)predicate;
+ (id)getItemWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getAllItems;
+ (NSArray *)getAllItemsUsingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value sortedBy:(NSString *)sortKey ascending:(BOOL)ascending;
+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value sortedBy:(NSString *)sortKey ascending:(BOOL)ascending usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value;
+ (NSArray *)getItemsWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsSortedByKey:(NSString *)key;
+ (NSArray *)getItemsSortedByKey:(NSString *)key ascending:(BOOL)ascending;
+ (NSArray *)getItemsSortedByKey:(NSString *)key ascending:(BOOL)ascending usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsWithSortDescriptors:(NSArray *)sortDescriptors;
+ (NSArray *)getItemsWithSortDescriptors:(NSArray *)sortDescriptors usingContext:(NSManagedObjectContext *)ctx;

+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors;
+ (NSArray *)getItemsWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors usingContext:(NSManagedObjectContext *)ctx;


#pragma mark - Get count


+ (NSUInteger)getCount;
+ (NSUInteger)getCountWithKey:(NSString *)key andValue:(id)value;
+ (NSUInteger)getCountWithKey:(NSString *)key andValue:(id)value usingContext:(NSManagedObjectContext *)ctx;
+ (NSUInteger)getCountWithPredicate:(NSPredicate *)predicate;
+ (NSUInteger)getCountWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx;


#pragma mark - delete


+ (void)deleteAllItems;
+ (void)deleteAllItemsUsingContext:(NSManagedObjectContext *)ctx;
+ (void)deleteItemsWithPredicate:(NSPredicate *)predicate usingContext:(NSManagedObjectContext *)ctx;


#pragma mark -


@end