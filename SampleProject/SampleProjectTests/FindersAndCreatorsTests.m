//
//  FindersAndCreatorsTests.m
//  SampleProject
//
//  Created by Marin Usalj on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FindersAndCreatorsTests.h"
#import "NSArray+Accessors.h"
#import "Kiwi.h"
#import "Person.h"

static NSString *UNIQUE_NAME = @"ldkhbfaewlfbaewljfhb";
static NSString *UNIQUE_SURNAME = @"laewfbaweljfbawlieufbawef";

SPEC_BEGIN(FindersAndCreators)

NSArray *names = [NSArray arrayWithObjects:@"John", @"Steve", @"Neo", UNIQUE_NAME, nil];
NSArray *surnames = [NSArray arrayWithObjects:@"Doe", @"Jobs", @"Anderson", UNIQUE_SURNAME, nil];

#pragma mark - Helpers

Person *(^fetchUniquePerson)(void) = ^Person *(void) {
    return  [Person where:[NSString stringWithFormat:@"name = '%@' AND surname = '%@'",
                                                    UNIQUE_NAME, UNIQUE_SURNAME]].first;
};

void (^createSomePeople)(void) = ^(void) {
    [names enumerateObjectsUsingBlock:^(id name, NSUInteger idx, BOOL *stop) {
        Person *person = [Person create];
        person.name = name;
        person.surname = [surnames objectAtIndex:idx];
        person.age = [NSNumber numberWithInt:idx];
        person.isMember = [NSNumber numberWithBool:YES];
        [person save];
    }];
};


#pragma mark - Specs

describe(@"Find / Create / Save / Delete specs", ^{

    beforeAll(^{
        [Person deleteAll];
        createSomePeople();
    });
    
    afterAll(^{
        [Person deleteAll];
    });
    
    context(@"Creating", ^{
        
        it(@"creates without arguments", ^{
            Person *person = [Person create];
            person.name = @"marin";
            person.surname = UNIQUE_SURNAME;            
            [[[[Person where:@"name == 'marin'"].first surname] should] equal:UNIQUE_SURNAME];
        });
        

        it(@"creates with dict", ^{
            NSArray *attributes = [NSArray arrayWithObjects:@"name", @"surname", @"age", nil];
            NSArray *values = [NSArray arrayWithObjects:@"marin", @"usalj", [NSNumber numberWithInt:23], nil];

            Person *person = [Person create:[NSDictionary dictionaryWithObjects:values 
                                                                        forKeys:attributes]];
            [[person.name should] equal:@"marin"];
            [[person.surname should] equal:@"usalj"];
            [[person.age should] equal:theValue(23)];
        });
        
    });
    
    context(@"Saving", ^{

        __block Person *person;

        beforeEach(^{
            person = fetchUniquePerson();
            person.name = @"changed attribute for save";
        });
        
        afterEach(^{
            person.name = UNIQUE_NAME;
            [person save];
        });

        it(@"uses the object's context", ^{
            [[person.managedObjectContext should] receive:@selector(save:)];
            [person save];
        });
        
        it(@"returns YES if save has succeeded", ^{
            [[theValue([person save]) should] beTrue];
            [[theValue([person save]) should] beTrue];
        });
        
        it(@"returns NO if save hasn't succeeded", ^{
            [[person.managedObjectContext should] receive:@selector(save:) andReturn:theValue(NO)];
            [[theValue([person save]) should] beFalse];
        });
        
    });
    
    context(@"Deleting", ^{
       
        it(@"Deletes the object from database with -delete", ^{
            [fetchUniquePerson() shouldNotBeNil];
            [[fetchUniquePerson().managedObjectContext should] receive:@selector(save:)];
            [fetchUniquePerson() delete];
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
    
    context(@"Finders", ^{
       
//        it(@"should support the simple args like [NSString stringWithFormat:]", ^{
//
//            Person *unique = [Person where:@"name == '%@'", UNIQUE_NAME];
//            [[unique.surname should] equal:UNIQUE_SURNAME];
//        });
        
        it(@"Finds ALL the entities!", ^{
            [[[Person all] should] haveCountOf:[names count]];
        });
        
        it(@"Finds using [Entity where: STRING]", ^{
            
            Person *unique = [Person where:[NSString stringWithFormat:@"name == '%@'",UNIQUE_NAME]].first;
            [[unique.surname should] equal:UNIQUE_SURNAME];
            
        });
        
        it(@"Finds using [Entity where: STRING and ARGUMENTS]", ^{
            
            Person *unique = [Person where:@"name == '%@'", UNIQUE_NAME].first;
            [[unique.surname should] equal:UNIQUE_SURNAME];
            
        });

        it(@"Finds using [Entity where: DICTIONARY]", ^{

            NSArray *attributes = [NSArray arrayWithObjects:@"name", @"surname", @"age", @"isMember", nil];
            NSArray *values =     [NSArray arrayWithObjects:@"John", @"Doe", [NSNumber numberWithInt:0], [NSNumber numberWithBool:YES], nil];

            
            Person *unique = [Person where:[NSDictionary dictionaryWithObjects:values 
                                                                       forKeys:attributes]].first;

            [[unique.name should] equal:@"John"];
            [[unique.surname should] equal:@"Doe"];
            [[unique.age should] equal:theValue(0)];
            [[unique.isMember should] equal:theValue(YES)];
        });
        
    });
    
    context(@"All from above, in a separate context!", ^{

        NSManagedObjectContext *newContext = [NSManagedObjectContext new]; 
        newContext.persistentStoreCoordinator = [[CoreDataManager instance] persistentStoreCoordinator];
        
        beforeAll(^{
            Person *newPerson = [Person createInContext:newContext];
            newPerson.name = @"Joshua";
            newPerson.age = [NSNumber numberWithInt:100];
            [newPerson save];
        });
        
        afterAll(^{
            [Person deleteAllInContext:newContext];
        });
        
        it(@"Finds in a separate context", ^{
            [[newContext should] receive:@selector(executeFetchRequest:error:)];
            Person *found = [Person where:@"name == 'Joshua'" inContext:newContext].first;
            [[found.name should] equal:@"Joshua"];
        });

        it(@"Finds ALL! in a separate context", ^{
            [[newContext should] receive:@selector(executeFetchRequest:error:)];
            [Person allInContext:newContext];
//TODO: NEED TO FIGURE THIS ONE OUT [[[Person allInContext:newContext] should] haveCountOf:[[Person all] count]+1];
        });
        
        it(@"Creates in a separate context", ^{
            [[NSEntityDescription should] 
             receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:) 
             andReturn:nil 
             withArguments:@"Person", newContext];
            
            [Person createInContext:newContext];
        });
        
        it(@"Creates in a separate context", ^{
            [[NSEntityDescription should] 
             receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:) 
             andReturn:nil 
             withArguments:@"Person", newContext];
            
            [Person create:[NSDictionary dictionary] inContext:newContext];
        });
        
        
    });
    
});

SPEC_END

