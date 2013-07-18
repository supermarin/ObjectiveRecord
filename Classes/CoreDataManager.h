//
//  CoreDataManager.h
//  WidgetPush
//
//  Created by Marin on 9/1/11.
//  Copyright (c) 2011 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (copy, nonatomic) NSString *databaseName;
@property (copy, nonatomic) NSString *modelName;

+ (id)instance DEPRECATED_ATTRIBUTE;
+ (instancetype)sharedManager;

- (BOOL)saveContext;
- (void)useInMemoryStore;

#pragma mark - Helpers

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationSupportDirectory;

@end
