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

#if TARGET_OS_IPHONE
    it(@"uses documents directory on iphone", ^{
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:@"/Documents/"];
    });
#else
    it(@"uses application support directory on osx", ^{
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:@"/Application Support/"];
    });
#endif

});

SPEC_END
