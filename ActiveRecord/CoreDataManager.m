//
//  CoreDataManager.m
//  WidgetPush
//
//  Created by Marin on 9/1/11.
//  Copyright (c) 2011 mneorr.com. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


static CoreDataManager *singleton;

- (id)initForSingleton {
    return [super init];
}

+ (id)instance {
    @synchronized(self) {
        if (!singleton)
            singleton = [[self alloc] initForSingleton];
    }
    return singleton;
}

- (BOOL)saveContext {
    if (self.managedObjectContext == nil) return NO;
    if (![self.managedObjectContext hasChanges])return NO;
        
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error in saving context! %@, %@", error, [error userInfo]);
        return NO;
    }
    
    return YES;
}


#pragma mark - Public

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext) return __managedObjectContext;
    
    if (self.persistentStoreCoordinator) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel) return __managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Database" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

-(void) setUpPersistentStoreCoordinator {
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"WidgetPush.sqlite"];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        NSLog(@"ERROR IN PERSISTENT STORE COORDINATOR! %@, %@", error, [error userInfo]);
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator) return __persistentStoreCoordinator;
    
    [self setUpPersistentStoreCoordinator];   
    return __persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
