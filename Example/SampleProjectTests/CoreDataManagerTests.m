//
//  CoreDataManagerTests.m
//  SampleProject
//
//  Created by Marin Usalj on 7/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import <ObjectiveRecord/CoreDataManager.h>

void resetToRealStore(CoreDataManager *manager) {
    [manager setValue:nil forKey:@"persistentStoreCoordinator"];
    [manager setValue:nil forKey:@"managedObjectContext"];
    [manager setValue:nil forKey:@"managedObjectModel"];
}

SPEC_BEGIN(CoreDataManagerTests)

describe(@"Core data stack", ^{
   
    CoreDataManager *manager = [CoreDataManager new];
    
    it(@"can use in-memory store", ^{
        [manager useInMemoryStore];
        NSPersistentStore *store = [manager.persistentStoreCoordinator persistentStores][0];
        [[store.type should] equal:NSInMemoryStoreType];

        resetToRealStore(manager);
    });
    
    it(@"uses documents directory on iphone", ^{
        [manager stub:@selector(isOSX) andReturn:theValue(NO)];
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:[manager applicationDocumentsDirectory].absoluteString];
    });
    
    it(@"uses application support directory on osx", ^{
        [manager stub:@selector(isOSX) andReturn:theValue(YES)];
        NSPersistentStore *store = manager.persistentStoreCoordinator.persistentStores[0];
        [[store.URL.absoluteString should] containString:[manager applicationDocumentsDirectory].absoluteString];
    });
    
});

SPEC_END
