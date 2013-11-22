//
//  FindersAndCreatorsTests.m
//  SampleProject
//
//  Created by Marin Usalj on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "ObjectiveSugar.h"
#import "Person.h"
#import "OBRPerson.h"

static NSString *UNIQUE_NAME = @"ldkhbfaewlfbaewljfhb";
static NSString *UNIQUE_SURNAME = @"laewfbaweljfbawlieufbawef";


#pragma mark - Helpers

Person *fetchUniquePerson() {
    Person *person = [Person where:[NSString stringWithFormat:@"firstName = '%@' AND lastName = '%@'",
                                    UNIQUE_NAME, UNIQUE_SURNAME]].first;
    return person;
}

NSManagedObjectContext *createNewContext() {
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    newContext.persistentStoreCoordinator = [[CoreDataManager sharedManager] persistentStoreCoordinator];
    return newContext;
}

void createSomePeople(NSArray *names, NSArray *surnames, NSManagedObjectContext *context) {
    for (int i = 0; i < names.count; i++) {
        Person *person = [Person createInContext:context];
        person.firstName = names[i];
        person.lastName = surnames[i];
        person.age = @(i);
        person.isMember = @YES;
        person.anniversary = [NSDate dateWithTimeIntervalSince1970:0];
        [person save];
    }
}


SPEC_BEGIN(FindersAndCreators)

describe(@"Find / Create / Save / Delete specs", ^{

    NSArray *names = @[@"John", @"Steve", @"Neo", UNIQUE_NAME];
    NSArray *surnames = @[@"Doe", @"Jobs", @"Anderson", UNIQUE_SURNAME];
    
    beforeEach(^{
        [Person deleteAll];
        createSomePeople(names, surnames, NSManagedObjectContext.defaultContext);
    });
    
    context(@"Finders", ^{
        
        it(@"Finds ALL the entities!", ^{
            [[[Person all] should] haveCountOf:[names count]];
        });
        
        it(@"Finds using [Entity where: STRING]", ^{
            
            Person *unique = [Person where:[NSString stringWithFormat:@"firstName == '%@'",UNIQUE_NAME]].first;
            [[unique.lastName should] equal:UNIQUE_SURNAME];
            
        });
        
        it(@"Finds using [Entity where: STRING and ARGUMENTS]", ^{
            
            Person *unique = [Person whereFormat:@"firstName == '%@'", UNIQUE_NAME].first;
            [[unique.lastName should] equal:UNIQUE_SURNAME];
            
        });
        
        it(@"Finds using [Entity where: DICTIONARY]", ^{
            Person *person = [Person where:@{
                @"firstName": @"John",
                @"lastName": @"Doe",
                @"age": @0,
                @"isMember": @1,
                @"anniversary": [NSDate dateWithTimeIntervalSince1970:0]
            }].first;
            
            [[person.firstName should] equal:@"John"];
            [[person.lastName should] equal:@"Doe"];
            [[person.age should] equal:@0];
            [[person.isMember should] equal:theValue(YES)];
            [[person.anniversary should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        });

        it(@"Finds and creates if there was no object", ^{
            [Person deleteAll];
            Person *luis = [Person findOrCreate:@{ @"firstName": @"Luis" }];
            [[luis.firstName should] equal:@"Luis"];
        });
        
        it(@"doesn't create duplicate objects on findOrCreate", ^{
            [Person deleteAll];
            [@4 times:^{
                [Person findOrCreate:@{ @"firstName": @"Luis" }];
            }];
            [[[Person all] should] haveCountOf:1];
        });

    });
    
    
    context(@"Creating", ^{
        
        it(@"creates without arguments", ^{
            Person *person = [Person create];
            person.firstName = @"marin";
            person.lastName = UNIQUE_SURNAME;
            [[[[Person where:@"firstName == 'marin'"].first lastName] should] equal:UNIQUE_SURNAME];
        });
        

        it(@"creates with dict", ^{
            Person *person = [Person create:@{
                @"firstName": @"Marin",
                @"lastName": @"Usalj",
                @"age": @25
            }];
            [[person.firstName should] equal:@"Marin"];
            [[person.lastName should] equal:@"Usalj"];
            [[person.age should] equal:theValue(25)];
        });
        
        it(@"Doesn't create with nulls", ^{
            [[Person create:nil] shouldBeNil];
            [[Person create:(id)[NSNull null]] shouldBeNil];
        });
        
    });
    
    context(@"Updating", ^{
       
        
        
        it(@"Can update using dictionary", ^{
            Person *person = [Person create];
            [person update:@{ @"firstName": @"Jonathan", @"age": @50 }];
            
            [[person.firstName should] equal:@"Jonathan"];
            [[person.age should] equal:@50];
        });
        
        it(@"doesn't set NSNull properties", ^{
            Person *person = [Person create];
            [person update:@{ @"is_member": [NSNull null] }];
            [person.isMember shouldBeNil];
        });
        
        it(@"stringifies numbers", ^{
            Person *person = [Person create:@{ @"first_name": @123 }];
            [[person.firstName should] equal:@"123"];
        });
        
        it(@"converts strings to integers", ^{
            Person *person = [Person create:@{ @"age": @"25" }];
            [[person.age should] equal:@25];
        });
        
        it(@"converts strings to floats", ^{
            Person *person = [Person create:@{ @"savings": @"1500.12" }];
            [[person.savings should] equal:@(1500.12f)];
        });
        
        it(@"converts strings to dates", ^{
            NSDateFormatter *formatta = [NSDateFormatter new];
            [formatta setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
            
            NSDate *date = [NSDate date];
            Person *person = [Person create:@{ @"anniversary": [formatta stringFromDate:date] }];
            [[@([date timeIntervalSinceDate:person.anniversary]) should] beLessThan:@1];
        });
        
        it(@"doesn't update with nulls", ^{
            Person *person = fetchUniquePerson();
            [person update:nil];
            [person update:(id)[NSNull null]];
            
            [[person.firstName should] equal:UNIQUE_NAME];
        });
        
    });
    
    context(@"Saving", ^{

        __block Person *person;

        beforeEach(^{
            person = fetchUniquePerson();
            person.firstName = @"changed attribute for save";
        });
        
        afterEach(^{
            person.firstName = UNIQUE_NAME;
            [person save];
        });

        it(@"uses the object's context", ^{
            [[person.managedObjectContext should] receive:@selector(save:) andReturn:theValue(YES)];
            [person save];
        });
        
        it(@"returns YES if save has succeeded", ^{
            [[@([person save]) should] beTrue];
            [[@([person save]) should] beTrue];
        });
        
        it(@"returns NO if save hasn't succeeded", ^{
            [[person.managedObjectContext should] receive:@selector(save:) andReturn:theValue(NO)];
            [[theValue([person save]) should] beFalse];
        });
        
    });
    
        
    context(@"Deleting", ^{
        
        it(@"Deletes the object from database with -delete", ^{
            Person *person = fetchUniquePerson();
            [person shouldNotBeNil];
            [[person.managedObjectContext should] receive:@selector(save:)];
            [person delete];
            [fetchUniquePerson() shouldBeNil];
        });
        
        it(@"Deletes everything from database with +deleteAll", ^{
            [[[NSManagedObjectContext defaultContext] should] receive:@selector(save:)
                                                            andReturn:nil
                                                            withCount:[Person all].count];
            [Person deleteAll];
            [[Person all] shouldBeNil];
        });
        
    });
    
    
    context(@"All from above, in a separate context!", ^{

        NSManagedObjectContext *newContext = createNewContext();
        
        beforeEach(^{
            [Person deleteAll];
            [newContext performBlockAndWait:^{
                Person *newPerson = [Person createInContext:newContext];
                newPerson.firstName = @"Joshua";
                newPerson.lastName = @"Jobs";
                newPerson.age = [NSNumber numberWithInt:100];
                [newPerson save];
            }];
        });
        
        it(@"Creates in a separate context", ^{
            [[NSEntityDescription should] 
             receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:) 
             andReturn:nil 
             withArguments:@"Person", newContext];
            
            [Person createInContext:newContext];
        });
        
        it(@"Creates in a separate context", ^{
            [[NSEntityDescription should] receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:)
                                    withArguments:@"Person", newContext];
            
            [Person create:[NSDictionary dictionary] inContext:newContext];
        });
        
        it(@"Finds in a separate context", ^{
            [newContext performBlock:^{
                Person *found = [Person where:@{ @"firstName": @"Joshua" } inContext:newContext].first;
                [[found.lastName should] equal:@"Jobs"];
            }];
        });
        
        it(@"Finds all in a separate context", ^{
            __block NSManagedObjectContext *anotherContext = createNewContext();
            __block NSArray *newPeople;

            [anotherContext performBlock:^{
                [Person deleteAll];
                createSomePeople(names, surnames, anotherContext);
                newPeople = [Person allInContext:anotherContext];
            }];

            [[expectFutureValue(newPeople) shouldEventually] haveCountOf:names.count];
        });
      
        it(@"Find or create in a separate context", ^{
            [newContext performBlock:^{
                [Person deleteAll];
                Person *luis = [Person findOrCreate:@{ @"firstName": @"Luis" } inContext:newContext];
                [[luis.firstName should] equal:@"Luis"];
            }];
        });
        
        it(@"Deletes all from context", ^{
            [Person deleteAllInContext:newContext];
            [[Person allInContext:newContext] shouldBeNil];
        });
        
    });
    
    
    context(@"With a different class name to the entity name", ^{
        
        NSManagedObjectContext *newContext = createNewContext();
        
        it(@"Has the correct entity name", ^{
            [[[OBRPerson entityName] should] equal:@"OtherPerson"];
        });
        
        it(@"Fetches the correct entity", ^{
            [[NSEntityDescription should] receive:@selector(entityForName:inManagedObjectContext:)
                                        andReturn:[NSEntityDescription entityForName:@"OtherPerson" inManagedObjectContext:newContext]
                                    withArguments:@"OtherPerson", newContext];
            
            [OBRPerson allInContext:newContext];
        });
        
        it(@"Creates the correct entity", ^{
            [[NSEntityDescription should] receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:)
                                    withArguments:@"OtherPerson", newContext];
            
            [OBRPerson createInContext:newContext];
        });
        
    });

    
});

SPEC_END

