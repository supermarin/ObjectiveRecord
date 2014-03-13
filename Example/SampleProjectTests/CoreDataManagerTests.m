#import "Kiwi.h"
#import <ObjectiveRecord/CoreDataManager.h>

void resetCoreDataStack(CoreDataManager *manager) {
    [manager setValue:nil forKey:@"persistentStoreCoordinator"];
    [manager setValue:nil forKey:@"managedObjectContext"];
    [manager setValue:nil forKey:@"managedObjectModel"];
}

SPEC_BEGIN(CoreDataManagerTests)

describe(@"Core data stack", ^{
   
    CoreDataManager *manager = [CoreDataManager new];

    afterEach(^{
        resetCoreDataStack(manager);
    });
    
    it(@"can use in-memory store", ^{
        [manager useInMemoryStore];
        NSPersistentStore *store = [manager.persistentStoreCoordinator persistentStores][0];
        [[store.type should] equal:NSInMemoryStoreType];
    });
    
    it(@"uses documents directory on iphone", ^{
        [manager stub:@selector(isOSX) andReturn:theValue(NO)];
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:[manager applicationDocumentsDirectory].absoluteString];
    });
    
    it(@"uses application support directory on osx", ^{
        [manager stub:@selector(isOSX) andReturn:theValue(YES)];
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:[manager applicationSupportDirectory].absoluteString];
    });
    
    it(@"creates application support directory on OSX if needed", ^{
        [manager stub:@selector(isOSX) andReturn:theValue(YES)];
        [[NSFileManager defaultManager] removeItemAtURL:manager.applicationSupportDirectory error:nil];

        NSPersistentStore *store = [manager.persistentStoreCoordinator persistentStores][0];
        [[store.URL.absoluteString should] endWithString:@".sqlite"];
    });
    
});

SPEC_END
