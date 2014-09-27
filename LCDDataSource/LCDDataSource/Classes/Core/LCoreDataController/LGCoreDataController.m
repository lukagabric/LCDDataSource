//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGCoreDataController.h"
#import <CoreData/CoreData.h>
#include <sys/xattr.h>


@implementation LGCoreDataController


@synthesize rootMOC = _rootMOC;
@synthesize mainMOC = _mainMOC;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - Singleton


+ (LGCoreDataController *)sharedCDController
{
	__strong static LGCoreDataController *sharedCDController = nil;
    
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
        sharedCDController = [LGCoreDataController new];
    });
    
	return sharedCDController;
}


#pragma mark - Initialize


- (void)initializeWithDatabaseFileName:(NSString *)databaseFileName andDataModelFileName:(NSString *)dataModelFileName
{
    _databaseFileName = databaseFileName;
    _dataModelFileName = dataModelFileName;
    
    [self rootMOC];
	[self mainMOC];
}


#pragma mark - Delete database


- (void)deleteDatabase
{
    if ([[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil])
    {
        _rootMOC = nil;
        _mainMOC = nil;
        _managedObjectModel = nil;
        _persistentStoreCoordinator = nil;
    }
}


#pragma mark - Core Data stack


- (NSURL *)storeURL
{
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

    return [[NSURL fileURLWithPath:[cachesPaths objectAtIndex:0]] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _databaseFileName]];
}


- (NSManagedObjectContext *)rootMOC
{
	if (_rootMOC != nil)
	{
		return _rootMOC;
	}
    
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
	if (coordinator != nil)
	{
		_rootMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		[_rootMOC setPersistentStoreCoordinator:coordinator];
	}
    
	return _rootMOC;
}


- (NSManagedObjectContext *)mainMOC
{
	if (_mainMOC != nil)
		return _mainMOC;
    
    _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainMOC.parentContext = self.rootMOC;

	return _mainMOC;
}


- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel != nil)
		return _managedObjectModel;

	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_dataModelFileName withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

	return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
		return _persistentStoreCoordinator;
    
	NSURL *storeURL = [self storeURL];

	NSError *error = nil;

	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

	NSDictionary *options = @{
		NSMigratePersistentStoresAutomaticallyOption : @YES,
		NSInferMappingModelAutomaticallyOption : @YES
	};

	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
		abort();
#endif
	}

	[self addSkipBackupAttributeToDatabase];

	return _persistentStoreCoordinator;
}


- (BOOL)addSkipBackupAttributeToDatabase
{
    NSString *path = [[self storeURL] path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
    
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


#pragma mark -


@end