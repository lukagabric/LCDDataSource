//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#define rootMOC() [[LGCoreDataController sharedCDController] rootMOC]
#define mainMOC() [[LGCoreDataController sharedCDController] mainMOC]


#import <Foundation/Foundation.h>


@interface LGCoreDataController : NSObject
{
	NSManagedObjectContext *_rootMOC;
	NSManagedObjectContext *_mainMOC;
	NSManagedObjectModel *_managedObjectModel;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSString *_databaseFileName;
    NSString *_dataModelFileName;
}


@property (readonly, nonatomic) NSManagedObjectContext *rootMOC;
@property (readonly, nonatomic) NSManagedObjectContext *mainMOC;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)initializeWithDatabaseFileName:(NSString *)databaseFileName andDataModelFileName:(NSString *)dataModelFileName;
- (void)deleteDatabase;


+ (LGCoreDataController *)sharedCDController;


@end