
#import "Kiwi.h"
#import "Person+Mappings.h"
#import "Car+Mappings.h"
#import "InsuranceCompany.h"
#import "CoreDataManager.h"
#import "JSONUtility.h"

SPEC_BEGIN(MappingsTests)

describe(@"Mappings", ^{
    
    __block Person *person;
    
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    newContext.persistentStoreCoordinator = [[CoreDataManager sharedManager] persistentStoreCoordinator];
    
    NSDictionary *payload = JSON(@"people");
    
    beforeEach(^{
        person = [Person create:payload inContext:newContext];
    });
    
    it(@"caches mappings", ^{
        Car *car = [Car createInContext:newContext];
        [[Car should] receive:@selector(mappings) withCountAtMost:1];
        
        [car update:@{ @"hp": @150 } inContext:newContext];
        [car update:@{ @"make": @"Ford" } inContext:newContext];
        [car update:@{ @"hp": @150 } inContext:newContext];
    });
    
    it(@"supports keypath nested property mappings", ^{
        Person *person = [Person createInContext:newContext];
        [[Person should] receive:@selector(mappings) withCountAtMost:1];
        [[Person should] receive:@selector(keyPathForRemoteKey:) withCountAtMost:16];
        
        [person update:@{ @"first_name": @"Marin", @"last_name": @"Usalj" } inContext:newContext];
        [person update:@{ @"profile": @{ @"role": @"CEO", @"life_savings": @1500.12 } } inContext:newContext];
    });
    
    it(@"uses mapped values when creating", ^{
        [[person.firstName should] equal:@"Marin"];
        [[person.lastName should] equal:@"Usalj"];
        [[person.age should] equal:@30];
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
        Person *bob = [Person updateOrCreate:@{ @"first_name": @"Bob" } inContext:newContext];
        [[bob.firstName should] equal:@"Bob"];
    });
    
    it(@"supports creating a parent object using just ID from the server", ^{
        Car *car = [Car create:@{ @"hp": @150, @"insurance_id": @1234 } inContext:newContext];
        [[car.insuranceCompany should] equal:[InsuranceCompany find:@{ @"remoteID": @1234 } inContext:newContext]];
    });

    it(@"supports creating nested objects directly", ^{
        Person *employee = [Person createInContext:newContext];
        Person *manager = [Person create:@{@"employees": @[employee]} inContext:newContext];
        [[[manager should] have:1] employees];
    });

    it(@"ignores unknown keys", ^{
        Car *car = [Car createInContext:newContext];
        [[car shouldNot] receive:@selector(setPrimitiveValue:forKey:)];
        [car update:@{ @"chocolate": @"waffles" } inContext:newContext];
    });

    it(@"ignores embedded unknown keys", ^{
        [[theBlock(^{
            Car *car = [Car createInContext:newContext];
            [car update:@{ @"owner": @{ @"coolness": @(100) } } inContext:newContext];
        }) shouldNot] raise];
    });

    it(@"supports creating nested parent objects using IDs from the server", ^{
        Car *car = [Car create:@{ @"insurance_company": @{ @"id" : @1234, @"owner_id" : @4567 }} inContext:newContext];
        [[car.insuranceCompany.owner should] equal:[Person find:@{ @"remoteID": @4567 } inContext:newContext]];
    });

    it(@"supports creating full nested parent objects", ^{
        Car *car = [Car create:@{ @"insurance_company": @{ @"id" : @1234, @"owner" : @{ @"id" : @4567, @"first_name" : @"Stan" } }} inContext:newContext];
        [[car.insuranceCompany.owner should] equal:[Person find:@{ @"remoteID": @4567, @"firstName": @"Stan" } inContext:newContext]];
    });
});

SPEC_END
