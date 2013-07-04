//
//  CoreDataManagerTests.m
//  SampleProject
//
//  Created by Marin Usalj on 7/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import <ObjectiveRecord/CoreDataManager.h>

SPEC_BEGIN(CoreDataManagerTests)

describe(@"Core data stack", ^{
   
    CoreDataManager *manager = [CoreDataManager instance];
    
    it(@"can use in-memory store", ^{
        [manager useInMemoryStore];
        NSPersistentStore *store = [manager.persistentStoreCoordinator persistentStores][0];
        [[store.type should] equal:NSInMemoryStoreType];
    });
    
});

SPEC_END
