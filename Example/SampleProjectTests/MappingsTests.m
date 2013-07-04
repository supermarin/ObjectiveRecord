//
//  MappingsTests.m
//  SampleProject
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "Person+Mappings.h"
#import "Car+Mappings.h"

SPEC_BEGIN(MappingsTests)

describe(@"Mappings", ^{
    
    NSDictionary *JSON = @{
        @"first_name": @"Marin",
        @"last_name": @"Usalj",
        @"age": @24,
        @"is_member": @YES,
        @"cars": @[
               @{ @"hp": @220, @"make": @"Trabant" },
               @{ @"hp": @90, @"make": @"Volkswagen" }
        ],
        @"manager": @{
               @"firstName": @"Delisa",
               @"lastName": @"Mason",
               @"age": @25,
               @"isMember": @NO
        },
        @"employees": @[
               @{ @"first_name": @"Luca" },
               @{ @"first_name": @"Tony" },
               @{ @"first_name": @"Jim" }
        ]
    };
    
    __block Person *person;
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    newContext.persistentStoreCoordinator = [[CoreDataManager sharedManager] persistentStoreCoordinator];
    
    beforeEach(^{
        person = [Person create:JSON inContext:newContext];
    });
    
    it(@"caches mappings", ^{
        Car *car = [Car createInContext:newContext];
        [[car should] receive:@selector(mappings) andReturn:@{ @"hp": @"horsePower" } withCount:1];
        
        [car update:@{ @"hp": @150 }];
        [car update:@{ @"make": @"Ford" }];
        [car update:@{ @"hp": @150 }];
    });
    
    it(@"uses mapped values when creating", ^{
        [[person.firstName should] equal:@"Marin"];
        [[person.lastName should] equal:@"Usalj"];
        [[person.age should] equal:@24];
    });
    
    it(@"can support snake_case even without mappings", ^{
        [[person.isMember should] beTrue];
    });
    
    it(@"supports nested properties", ^{
        [[[person should] have:2] cars];
    });
    
    it(@"supports to one relationship", ^{
        [[person.manager.firstName should] equal:@"Delisa"];
    });
    
    it(@"supports to many relationship", ^{
       [[[person should] have:3] employees];
    });
    
});

SPEC_END
