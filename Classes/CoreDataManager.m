// CoreDataManager.m
//
// Copyright (c) 2014 Marin Usalj <http://supermar.in>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CoreDataManager.h"

@implementation CoreDataManager
@synthesize privateManagedObjectContext = _privateManagedObjectContext;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
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
    return [[NSBundle bundleForClass:[self class]] infoDictionary][@"CFBundleName"];
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

- (NSManagedObjectContext *)mainManagedObjectContext {
    if (_mainManagedObjectContext) return _mainManagedObjectContext;
    
    if (self.persistentStoreCoordinator) {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)privateManagedObjectContext {
    NSManagedObjectContext *tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [tempContext setParentContext:self.mainManagedObjectContext];
    
    return tempContext;
}

#pragma mark - Public

- (NSManagedObjectContext *)managedObjectContext {
    if ([NSThread isMainThread]) {
        return [self mainManagedObjectContext];
    } else {
        return [self privateManagedObjectContext];
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) return _managedObjectModel;

    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:[self modelName] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;

    _persistentStoreCoordinator = [self persistentStoreCoordinatorWithStoreType:NSSQLiteStoreType
                                                                       storeURL:[self sqliteStoreURL]];
    return _persistentStoreCoordinator;
}

- (void)useInMemoryStore {
    _persistentStoreCoordinator = [self persistentStoreCoordinatorWithStoreType:NSInMemoryStoreType storeURL:nil];
}

- (BOOL)save:(NSManagedObjectContext *)context {
    if (context.concurrencyType == NSPrivateQueueConcurrencyType) {
        BOOL privateSaveResult = [self saveContext:context];
        if (privateSaveResult) {
            __block BOOL mainSaveResult;
            NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
            [mainContext performBlockAndWait:^{
                mainSaveResult = [self save:mainContext];
            }];
            return mainSaveResult;
        } else {
            return NO;
        }
    } else {
        return [self saveContext:[self mainManagedObjectContext]];
    }
}

- (BOOL)saveContext:(NSManagedObjectContext *)context {
    if (context == nil) return NO;
    if (![context hasChanges])return NO;
    
    NSError *error = nil;

    if (![context save:&error]) {
        NSLog(@"Unresolved error in saving context! %@, %@", error, [error userInfo]);
        return NO;
    }

    return YES;
}

- (void)createAndAddPersistentStore:(NSPersistentStoreCoordinator *)coordinator
                           storeURL:(NSURL *)storeURL
                          storeType:(NSString *const)storeType {
    @synchronized(self) {
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES };
        
        NSError *error = nil;
        if (![coordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error])
            NSLog(@"ERROR WHILE CREATING PERSISTENT STORE COORDINATOR! %@, %@", error, [error userInfo]);
    }
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
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    [self createAndAddPersistentStore:coordinator storeURL:storeURL storeType:storeType];
    
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
