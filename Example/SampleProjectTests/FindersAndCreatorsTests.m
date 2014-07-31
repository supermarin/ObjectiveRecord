
#import "Kiwi.h"
#import "ObjectiveSugar.h"
#import "Person+Mappings.h"
#import "OBRPerson.h"
#import "Car+Mappings.h"
#import "CoreDataManager.h"

static NSString *UNIQUE_NAME = @"ldkhbfaewlfbaewljfhb";
static NSString *UNIQUE_SURNAME = @"laewfbaweljfbawlieufbawef";


#pragma mark - Helpers

Person *fetchUniquePerson() {
    Person *person = [Person where:[NSString stringWithFormat:@"firstName = '%@' AND lastName = '%@'",
                                    UNIQUE_NAME, UNIQUE_SURNAME] inContext:[CoreDataManager context]].first;
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
        [person saveInContext:[CoreDataManager context]];
    }
}


SPEC_BEGIN(FindersAndCreators)

describe(@"Find / Create / Save / Delete specs", ^{

    NSArray *names = @[@"John", @"Steve", @"Neo", UNIQUE_NAME];
    NSArray *surnames = @[@"Doe", @"Jobs", @"Anderson", UNIQUE_SURNAME];

    beforeEach(^{
        [Person deleteAllInContext:[CoreDataManager context]];
        createSomePeople(names, surnames, [CoreDataManager context]);
    });

    context(@"Finders", ^{

        it(@"Finds ALL the entities!", ^{
            [[[Person allInContext:[CoreDataManager context]] should] haveCountOf:[names count]];
        });

        it(@"Finds using [Entity where: STRING]", ^{

            Person *unique = [Person where:[NSPredicate predicateWithFormat:@"firstName == %@",UNIQUE_NAME] inContext:[CoreDataManager context]].first;
            [[unique.lastName should] equal:UNIQUE_SURNAME];

        });

        it(@"Finds using [Entity where: STRING and ARGUMENTS]", ^{

            Person *unique = [Person where:[NSPredicate predicateWithFormat:@"firstName == %@",UNIQUE_NAME] inContext:[CoreDataManager context]].first;
            [[unique.lastName should] equal:UNIQUE_SURNAME];

        });

        it(@"Finds using [Entity where: DICTIONARY]", ^{
            id condition = @{
                             @"firstName": @"John",
                             @"lastName": @"Doe",
                             @"age": @0,
                             @"isMember": @1,
                             @"anniversary": [NSDate dateWithTimeIntervalSince1970:0]
                             };
            Person *person = [Person where:condition inContext:[CoreDataManager context]].first;

            [[person.firstName should] equal:@"John"];
            [[person.lastName should] equal:@"Doe"];
            [[person.age should] equal:@0];
            [[person.isMember should] equal:@(YES)];
            [[person.anniversary should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        });

        it(@"Finds and creates if there was no object", ^{
            [Person deleteAllInContext:[CoreDataManager context]];
            Person *luis = [Person findOrCreate:@{@"firstName": @"Luis"} inContext:[CoreDataManager context]];
            [[luis.firstName should] equal:@"Luis"];
        });

        it(@"doesn't create duplicate objects on findOrCreate", ^{
            [Person deleteAllInContext:[CoreDataManager context]];
            [@4 times:^{
                [Person findOrCreate:@{@"firstName": @"Luis"} inContext:[CoreDataManager context]];
            }];
            [[[Person allInContext:[CoreDataManager context]] should] haveCountOf:1];
        });

        it(@"Finds the first match", ^{
            Person *johnDoe = [Person find:@{@"firstName": @"John",
                                              @"lastName": @"Doe"} inContext:[CoreDataManager context]];
            [[johnDoe.firstName should] equal:@"John"];
        });

        it(@"Finds the first match using [Entity find: STRING]", ^{
            Person *johnDoe = [Person find:@"firstName = 'John' AND lastName = 'Doe'" inContext:[CoreDataManager context]];
            [[johnDoe.firstName should] equal:@"John"];
        });

        it(@"Finds the first match using [Entity find: STRING and ARGUMENTS]", ^{
            Person *johnDoe = [Person find:[NSPredicate predicateWithFormat:@"firstName = %@ AND lastName = %@", @"John", @"Doe"] inContext:[CoreDataManager context]];
            [[johnDoe.firstName should] equal:@"John"];
        });

        it(@"doesn't create an object on find", ^{
            Person *cat = [Person find:@{@"firstName": @"Cat"} inContext:[CoreDataManager context]];
            [cat shouldBeNil];
        });

        it(@"Finds a limited number of results", ^{
            [@4 times:^{
                Person *newPerson = [Person createInContext:[CoreDataManager context]];
                newPerson.firstName = @"John";
                [newPerson saveInContext:[CoreDataManager context]];
            }];
            [[[Person where:@{@"firstName": @"John"} inContext:[CoreDataManager context] limit:@2] should] haveCountOf:2];
        });
    });

    context(@"Ordering", ^{

        id (^firstNameMapper)(Person *) = ^id (Person *p) { return p.firstName; };
        id (^lastNameMapper)(Person *) = ^id (Person *p) { return p.lastName; };

        beforeEach(^{
            [Person deleteAllInContext:[CoreDataManager context]];
            createSomePeople(@[@"Abe", @"Bob", @"Cal", @"Don"],
                             @[@"Zed", @"Mol", @"Gaz", @"Mol"],
                             [CoreDataManager context]);
        });

        it(@"orders results by a single string property", ^{
            NSArray *resultLastNames = [[Person allInContext:[CoreDataManager context] order:@"lastName"]
                                        map:lastNameMapper];
            [[resultLastNames should] equal:@[@"Gaz", @"Mol", @"Mol", @"Zed"]];
        });

        it(@"orders results by a single string property descending", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@"firstName DESC"]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Don", @"Cal", @"Bob", @"Abe"]];
        });

        it(@"orders results by multiple string properties descending", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@"lastName, firstName DESC"]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Cal", @"Don", @"Bob", @"Abe"]];
        });

        it(@"orders results by multiple properties", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@[@"lastName", @"firstName"]]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Cal", @"Bob", @"Don", @"Abe"]];
        });

        it(@"orders results by property ascending", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@{@"firstName" : @"ASC"}]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Abe", @"Bob", @"Cal", @"Don"]];
        });

        it(@"orders results by property descending", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@[@{@"firstName" : @"DESC"}]]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Don", @"Cal", @"Bob", @"Abe"]];
        });

        it(@"orders results by sort descriptors", ^{
            NSArray *resultFirstNames = [[Person allInContext:[CoreDataManager context] order:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                                                                [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO]]]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Cal", @"Don", @"Bob", @"Abe"]];
        });

        it(@"orders found results", ^{
            NSArray *resultFirstNames = [[Person where:@{@"lastName" : @"Mol"} inContext:[CoreDataManager context] order:@"firstName"]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Bob", @"Don"]];
        });

        it(@"orders limited results", ^{
            NSArray *resultLastNames = [[Person where:nil inContext:[CoreDataManager context] order:@"lastName" limit:@(2)]
                                        map:lastNameMapper];
            [[resultLastNames should] equal:@[@"Gaz", @"Mol"]];
        });

        it(@"orders found and limited results", ^{
            NSArray *resultFirstNames = [[Person where:@{@"lastName" : @"Mol"}
                                             inContext:[CoreDataManager context]
                                                 order:@[@{@"lastName" : @"ASC"},
                                                         @{@"firstName" : @"DESC"}]
                                                 limit:@(1)]
                                         map:firstNameMapper];
            [[resultFirstNames should] equal:@[@"Don"]];
        });
    });

    context(@"Counting", ^{

        it(@"counts all entities", ^{
            [[@([Person countInContext:[CoreDataManager context]]) should] equal:@(4)];
        });

        it(@"counts found entities", ^{
            NSUInteger count = [Person countWhere:@{@"firstName" : @"Neo"} inContext:[CoreDataManager context]];
            [[@(count) should] equal:@(1)];
        });

        it(@"counts zero when none found", ^{
            NSUInteger count = [Person countWhere:@{@"firstName" : @"Nobody"} inContext:[CoreDataManager context]];
            [[@(count) should] equal:@(0)];
        });

        it(@"counts with variable arguments", ^{
            NSUInteger count = [Person countWhere:[NSPredicate predicateWithFormat:@"firstName = %@", @"Neo"] inContext:[CoreDataManager context]];
            [[@(count) should] equal:@(1)];
        });
    });

    context(@"Creating", ^{

        it(@"creates without arguments", ^{
            Person *person = [Person createInContext:[CoreDataManager context]];
            person.firstName = @"marin";
            person.lastName = UNIQUE_SURNAME;
            [[[[Person where:@"firstName == 'marin'" inContext:[CoreDataManager context]].first lastName] should] equal:UNIQUE_SURNAME];
        });


        it(@"creates with dict", ^{
            Person *person = [Person create:@{
                @"firstName": @"Marin",
                @"lastName": @"Usalj",
                @"age": @25
            } inContext:[CoreDataManager context]];
            [[person.firstName should] equal:@"Marin"];
            [[person.lastName should] equal:@"Usalj"];
            [[person.age should] equal:theValue(25)];
        });

        it(@"Doesn't create with nulls", ^{
            [[Person create:nil inContext:[CoreDataManager context]] shouldBeNil];
            [[Person create:(id)[NSNull null] inContext:[CoreDataManager context]] shouldBeNil];
        });

    });

    context(@"Updating", ^{

        it(@"Can update using dictionary", ^{
            Person *person = [Person createInContext:[CoreDataManager context]];
            [person update:@{ @"firstName": @"Jonathan", @"age": @50 } inContext:[CoreDataManager context]];

            [[person.firstName should] equal:@"Jonathan"];
            [[person.age should] equal:@50];
        });

        it(@"sets [NSNull null] properties as nil", ^{
            Person *person = [Person createInContext:[CoreDataManager context]];
            [person update:@{ @"is_member": @YES } inContext:[CoreDataManager context]];
            [person update:@{ @"is_member": [NSNull null] } inContext:[CoreDataManager context]];
            [person.isMember shouldBeNil];
        });

        it(@"stringifies numbers", ^{
            Person *person = [Person create:@{ @"first_name": @123 } inContext:[CoreDataManager context]];
            [[person.firstName should] equal:@"123"];
        });

        it(@"converts strings to integers", ^{
            Person *person = [Person create:@{ @"age": @"25" } inContext:[CoreDataManager context]];
            [[person.age should] equal:@25];
        });

        pending(@"converts strings to floats", ^{
            Person *person = [Person create:@{ @"savings": @"1500.12" } inContext:[CoreDataManager context]];
            [[person.lifeSavings should] equal:@(1500.12f)];
        });

        it(@"converts strings to dates", ^{
            NSDateFormatter *formatta = [NSDateFormatter new];
            [formatta setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];

            NSDate *date = [NSDate date];
            Person *person = [Person create:@{ @"anniversary": [formatta stringFromDate:date] } inContext:[CoreDataManager context]];
            [[@([date timeIntervalSinceDate:person.anniversary]) should] beLessThan:@1];
        });

        it(@"doesn't update with nulls", ^{
            Person *person = fetchUniquePerson();
            [person update:nil inContext:[CoreDataManager context]];
            [person update:(id)[NSNull null] inContext:[CoreDataManager context]];

            [[person.firstName should] equal:UNIQUE_NAME];
        });

        it(@"doesn't always create new relationship object", ^{
            Car *car = [Car create:@{ @"hp": @150, @"owner": @{ @"firstName": @"asetnset" } } inContext:[CoreDataManager context]];
            [@3 times:^{
                [car update:@{ @"make": @"Porsche", @"owner": @{ @"firstName": @"asetnset" } } inContext:[CoreDataManager context]];
            }];
            [[[Person where:@{ @"firstName": @"asetnset" } inContext:[CoreDataManager context]] should] haveCountOf:1];
        });

        it(@"doesn't mark records as having changes when values are the same", ^{
            Person *person = fetchUniquePerson();
            [person update:@{@"firstName": person.firstName} inContext:[CoreDataManager context]];
            [[@([person hasChanges]) should] beNo];
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
            [person saveInContext:[CoreDataManager context]];
        });

        it(@"uses the object's context", ^{
            [[person.managedObjectContext should] receive:@selector(save:) andReturn:theValue(YES)];
            [person saveInContext:[CoreDataManager context]];
        });

        it(@"returns YES if save has succeeded", ^{
            [[@([person saveInContext:[CoreDataManager context]]) should] beTrue];
            [[@([person saveInContext:[CoreDataManager context]]) should] beTrue];
        });

        it(@"returns NO if save hasn't succeeded", ^{
            [[person.managedObjectContext should] receive:@selector(save:) andReturn:theValue(NO)];
            [[@([person saveInContext:[CoreDataManager context]]) should] beFalse];
        });

    });


    context(@"Deleting", ^{

        it(@"Deletes the object from database with -delete", ^{
            Person *person = fetchUniquePerson();
            [person shouldNotBeNil];
            [person deleteInContext:[CoreDataManager context]];
            [fetchUniquePerson() shouldBeNil];
        });

        it(@"Deletes everything from database with +deleteAll", ^{
            [Person deleteAllInContext:[CoreDataManager context]];
            [[[Person allInContext:[CoreDataManager context]] should] beEmpty];
        });

    });


    context(@"All from above, in a separate context!", ^{

        __block NSManagedObjectContext *newContext;

        beforeEach(^{
            [Person deleteAllInContext:[CoreDataManager context]];
            [[CoreDataManager context] save:nil];

            newContext = createNewContext();

            [newContext performBlockAndWait:^{
                Person *newPerson = [Person createInContext:newContext];
                newPerson.firstName = @"Joshua";
                newPerson.lastName = @"Jobs";
                newPerson.age = [NSNumber numberWithInt:100];
                [newPerson saveInContext:[CoreDataManager context]];
            }];
        });

        it(@"Creates in a separate context", ^{
            [[NSEntityDescription should] receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:)
                                        andReturn:nil
                                    withArguments:@"Person", newContext];

            [Person createInContext:newContext];
        });

        it(@"Creates with dictionary in a separate context", ^{
            [[NSEntityDescription should] receive:@selector(insertNewObjectForEntityForName:inManagedObjectContext:)
                                    withArguments:@"Person", newContext];

            [Person create:[NSDictionary dictionary] inContext:newContext];
        });

        it(@"Finds in a separate context", ^{
            [newContext performBlockAndWait:^{
                Person *found = [Person where:@{ @"firstName": @"Joshua" } inContext:newContext].first;
                [[found.lastName should] equal:@"Jobs"];
            }];
        });

        it(@"Finds all in a separate context", ^{
            __block NSManagedObjectContext *anotherContext = createNewContext();
            __block NSArray *newPeople;

            [anotherContext performBlockAndWait:^{
                [Person deleteAllInContext:[CoreDataManager context]];
                [[CoreDataManager context] save:nil];

                createSomePeople(names, surnames, anotherContext);
                newPeople = [Person allInContext:anotherContext];
            }];

            [[newPeople should] haveCountOf:names.count];
        });

        it(@"Finds the first match in a separate context", ^{
            NSDictionary *attributes = @{ @"firstName": @"Joshua",
                                          @"lastName": @"Jobs" };
            Person *joshua = [Person find:attributes inContext:newContext];
            [[joshua.firstName should] equal:@"Joshua"];
        });

        it(@"Finds a limited number of results in a separate context", ^{
            [@4 times:^{
                [newContext performBlockAndWait:^{
                    Person *newPerson = [Person createInContext:newContext];
                    newPerson.firstName = @"Joshua";
                    [newPerson saveInContext:[CoreDataManager context]];
                }];
            }];
            NSArray *people = [Person where:@{ @"firstName": @"Joshua"}
                                  inContext:newContext
                                      limit:@2];
            [[people should] haveCountOf:2];
        });


        it(@"Find or create in a separate context", ^{
            [newContext performBlockAndWait:^{
                Person *luis = [Person findOrCreate:@{ @"firstName": @"Luis" } inContext:newContext];
                [[luis.firstName should] equal:@"Luis"];
            }];
        });

        it(@"Deletes all from context", ^{
            [newContext performBlockAndWait:^{
                [Person deleteAllInContext:newContext];
                [[[Person allInContext:newContext] should] beEmpty];
            }];
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

