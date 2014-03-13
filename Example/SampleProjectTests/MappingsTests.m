#import "Kiwi.h"
#import "Person+Mappings.h"
#import "Car+Mappings.h"
#import "InsuranceCompany.h"

SPEC_BEGIN(MappingsTests)

describe(@"Mappings", ^{
    
    NSDictionary *JSON = @{
        @"first_name": @"Marin",
        @"last_name": @"Usalj",
        @"age": @25,
        @"is_member": @"true",
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
        [[Car should] receive:@selector(mappings) withCountAtMost:1];
        
        [car update:@{ @"hp": @150 }];
        [car update:@{ @"make": @"Ford" }];
        [car update:@{ @"hp": @150 }];
    });
    
    it(@"uses mapped values when creating", ^{
        [[person.firstName should] equal:@"Marin"];
        [[person.lastName should] equal:@"Usalj"];
        [[person.age should] equal:@25];
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
    
    it(@"uses mappings in findOrCreate", ^{
        Person *bob = [Person findOrCreate:@{ @"first_name": @"Bob" }];
        [[bob.firstName should] equal:@"Bob"];
    });
    
    it(@"supports creating a parent object using just ID from the server", ^{
        Car *car = [Car create:@{ @"hp": @150, @"insurance_id": @1234 }];
        [[car.insuranceCompany should] equal:[InsuranceCompany find:@{ @"remoteID": @1234 }]];
    });

    it(@"supports creating nested objects directly", ^{
        Person *employee = [Person create];
        Person *manager = [Person create:@{@"employees": @[employee]}];
        [[[manager should] have:1] employees];
    });
    
});

SPEC_END
