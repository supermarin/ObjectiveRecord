//
//  FindersAndCreatorsTests.m
//  SampleProject
//
//  Created by Marin Usalj on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FindersAndCreatorsTests.h"
#import "Kiwi.h"
#import "Person.h"

static NSString *UNIQUE_NAME = @"ldkhbfaewlfbaewljfhb";
static NSString *UNIQUE_SURNAME = @"laewfbaweljfbawlieufbawef";

SPEC_BEGIN(FindersAndCreators)

#pragma mark - Helpers

Person *(^fetchUniquePerson)(void) = ^Person *(void) {
    return  [Person where:[NSString stringWithFormat:@"name = '%@' AND surname = '%@'",
                                                    UNIQUE_NAME, UNIQUE_SURNAME]].first;
};

void (^createSomePeople)(void) = ^(void) {
    NSArray *names = [NSArray arrayWithObjects:@"John", @"Steve", @"Neo", UNIQUE_NAME, nil];
    NSArray *surnames = [NSArray arrayWithObjects:@"Doe", @"Jobs", @"Anderson", UNIQUE_SURNAME, nil];

    [names enumerateObjectsUsingBlock:^(id name, NSUInteger idx, BOOL *stop) {
        Person *person = [Person create];
        person.name = name;
        person.surname = [surnames objectAtIndex:idx];
        person.age = [NSNumber numberWithInt:idx];
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
        
    });
    
    context(@"Saving", ^{
        
    });
    
    context(@"Deleting", ^{
       
        it(@"Deletes the object from database with -delete", ^{
            [fetchUniquePerson() shouldNotBeNil];
            [fetchUniquePerson() delete];
            [fetchUniquePerson() shouldBeNil];
        });
        
        it(@"Deletes everything from database with +deleteAll", ^{
            [Person deleteAll];
            [[Person all] shouldBeNil];
        });
        
    });
    
    context(@"Finders", ^{
       
//        it(@"should support the simple args like [NSString stringWithFormat:]", ^{
//            Person *unique = [Person where:@"name == '%@'", UNIQUE_NAME];
//            [[unique.surname should] equal:UNIQUE_SURNAME];
//        });
        
        it(@"Finds using [Entity where: STRING]", ^{
            
            Person *unique = [Person where:[NSString stringWithFormat:@"name == '%@'",UNIQUE_NAME]].first;
            [[unique.surname should] equal:UNIQUE_SURNAME];
            
        });

        it(@"Finds using [Entity where: DICTIONARY]", ^{
            Person *unique = [Person where:[NSDictionary dictionaryWithObject:UNIQUE_SURNAME forKey:@"surname"]].first;
            [[unique.name should] equal:UNIQUE_NAME];
        });
        
    });
    
});

SPEC_END

