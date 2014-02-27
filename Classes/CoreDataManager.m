//
//  CoreDataManager.m
//  WidgetPush
//
//  Created by Marin on 9/1/11.
//  Copyright (c) 2011 mneorr.com. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager
@synthesize managedObjectContexts = _managedObjectContexts;
@synthesize defaultManagedObjectContext = _defaultManagedObjectContext;
@synthesize defaultManagedObjectModel = _defaultManagedObjectModel;
@synthesize defaultPersistentStoreCoordinator = _defaultPersistentStoreCoordinator;
@synthesize databaseName = _databaseName;
@synthesize modelName = _modelName;


+ (id)instance {
    return [self sharedManager];
}

+ (instancetype)sharedManager {
    static CoreDataManager *singleton;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}


#pragma mark - Private

- (NSString *)appName {
    return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"];
}

- (NSString *)databaseName {
    if (_databaseName != nil) return _databaseName;
    
    _databaseName = [[[self appName] stringByAppendingString:@".sqlite"] copy];
    return _databaseName;
}

- (NSString *)modelName {
    if (_modelName != nil) return _modelName;

    _modelName = [[self appName] copy];
    return _modelName;
}


#pragma mark - Public

- (NSManagedObjectContext *)defaultManagedObjectContext {
    if (_defaultManagedObjectContext) return _defaultManagedObjectContext;
    
    if (self.defaultPersistentStoreCoordinator) {
        _defaultManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_defaultManagedObjectContext setPersistentStoreCoordinator:self.defaultPersistentStoreCoordinator];
    }
    return _defaultManagedObjectContext;
}

- (NSManagedObjectModel *)defaultManagedObjectModel {
    if (_defaultManagedObjectModel) return _defaultManagedObjectModel;
    
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:[self modelName] withExtension:@"momd"];
    _defaultManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _defaultManagedObjectModel;
}

- (NSPersistentStoreCoordinator *)defaultPersistentStoreCoordinator {
    if (_defaultPersistentStoreCoordinator) return _defaultPersistentStoreCoordinator;
    
    _defaultPersistentStoreCoordinator = [self persistentStoreCoordinatorWithStoreType:NSSQLiteStoreType
                                                                              storeURL:[self sqliteStoreURL]];
    return _defaultPersistentStoreCoordinator;
}

- (void)useInMemoryStore {
  [self setInMemoryStoreAsDefault];
}

- (void)setInMemoryStoreAsDefault
{
   _defaultPersistentStoreCoordinator = [self persistentStoreCoordinatorWithStoreType:NSInMemoryStoreType storeURL:nil];
}

- (NSDictionary *)managedObjectContexts
{
  if (_managedObjectContexts == nil) _managedObjectContexts = [NSDictionary dictionaryWithObject:self.defaultManagedObjectContext forKey:@"default"];
  return _managedObjectContexts;
}

- (void)addContext:(NSManagedObjectContext *)context identifier:(NSString *)identifier
{
  NSMutableDictionary* contexts = [NSMutableDictionary dictionaryWithDictionary:self.managedObjectContexts];
  [contexts setObject:context forKey:identifier];
  _managedObjectContexts = contexts;
}

- (void)removeContextWithIdentifier:(NSString *)identifier
{
  NSMutableDictionary* contexts = [NSMutableDictionary dictionaryWithDictionary:self.managedObjectContexts];
  [contexts setObject:nil forKey:identifier];
  _managedObjectContexts = contexts;
}

- (void)save
{
  for (NSString* identifier in [self.managedObjectContexts allKeys]) {
    [self saveContext:identifier];
  }
}

- (BOOL)saveContext:(id)context
{
  
  if (context == nil) return NO;
  
  NSManagedObjectContext* objectContext;
  if ([context isKindOfClass:[NSString class]]) {
    objectContext = self.managedObjectContexts[context];
    if (objectContext == nil) return NO;
  } else if ([context isKindOfClass:[NSManagedObjectContext class]]) objectContext = context;
  
  if (![objectContext hasChanges])return NO;
  
  NSError *error = nil;
  
  if (![objectContext save:&error]) {
    NSLog(@"Unresolved error in saving context! %@, %@", error, [error userInfo]);
    return NO;
  }
  
  return YES;
}

- (BOOL)saveContext {
    if (self.defaultManagedObjectContext == nil) return NO;
    if (![self.defaultManagedObjectContext hasChanges])return NO;
    
    NSError *error = nil;
    
    if (![self.defaultManagedObjectContext save:&error]) {
        NSLog(@"Unresolved error in saving context! %@, %@", error, [error userInfo]);
        return NO;
    }
    
    return YES;
}


#pragma mark - SQLite file directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationSupportDirectory {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                   inDomains:NSUserDomainMask] lastObject]
            URLByAppendingPathComponent:[self appName]];
}


#pragma mark - Private

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreType:(NSString *const)storeType
                                                                 storeURL:(NSURL *)storeURL {
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self defaultManagedObjectModel]];
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
                               NSInferMappingModelAutomaticallyOption: @YES };

    NSError *error = nil;
    if (![coordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error])
        NSLog(@"ERROR WHILE CREATING PERSISTENT STORE COORDINATOR! %@, %@", error, [error userInfo]);
    
    return coordinator;
}

- (NSURL *)sqliteStoreURL {
    NSURL *directory = [self isOSX] ? self.applicationSupportDirectory : self.applicationDocumentsDirectory;
    NSURL *databaseDir = [directory URLByAppendingPathComponent:[self databaseName]];
    
    [self createApplicationSupportDirIfNeeded:directory];
    return databaseDir;
}

- (BOOL)isOSX {
    if (NSClassFromString(@"UIDevice")) return NO;
    return YES;
}

- (void)createApplicationSupportDirIfNeeded:(NSURL *)url {
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString]) return;

    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES attributes:nil error:nil];
}

@end
