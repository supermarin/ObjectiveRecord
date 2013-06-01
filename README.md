## Intro
This is a lightweight ActiveRecord way of managing Core Data objects.
The syntax is borrowed from Ruby on Rails.<br>
And yeah, no AppDelegate code.
It's fully tested with [Kiwi](https://github.com/allending/Kiwi).

[![Build Status](https://travis-ci.org/mneorr/Objective-Record.png?branch=master)](https://travis-ci.org/mneorr/Objective-Record)

#### Usage
1. Install with [CocoaPods](http://cocoapods.org) or clone
2. `#import "ObjectiveRecord.h"` in your model or .pch file.

#### Create / Save / Delete

``` objc
Person *john = [Person create];
john.name = @"John";
[john save];
[john delete];

[Person create:@{ @"name" : @"John", @"age" : @12, @"member" : @NO }];
```

#### Finders

``` objc
// all Person entities from the database
NSArray *people = [Person all];

// Person entities with name John
NSArray *johns = [Person where:@"name == 'John'"];

// And of course, John Doe!
Person *johnDoe = [Person where:@"name == 'John' AND surname == 'Doe'"].first;

// Members over 18 from NY
NSArray *people = [Person where:@{ 
                      @"age" : @18,
                      @"member" : @YES,
                      @"state" : @"NY"
                  }];

// I wanna be fancy and write my own NSPredicate
NSPredicate *membersPredicate = [NSPredicate  predicateWithBlock:^BOOL(Person *person, NSDictionary *bindings) {
    return person.isMember == YES;
}];
NSArray *members = [Person where:membersPredicate];
```

#### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
newContext.persistentStoreCoordinator = [[CoreDataManager instance] persistentStoreCoordinator];

Person *john = [Person createInContext:newContext];
Person *john = [Person where:@"name == 'John'" inContext:newContext].first;
NSArray *people = [Person allInContext:newContext];
```

#### Custom CoreData model or .sqlite database
If you've added the Core Data manually, you can change the custom model and database name on CoreDataManager
``` objc
[CoreDataManager instance].modelName = @"MyModelName";
[CoreDataManager instance].databaseName = @"custom_database_name";
```

#### Examples

``` objc
// find
[[Person all] each:^(Person *person) {
    person.member = @NO;
}];

for(Person *person in [Person all]) {
    person.member = @YES;
}

// create / save
Person *john = [Person create];
john.name = @"John";
john.surname = @"Wayne";
[john save];

// find / delete
[[Person where: @{ "member" : @NO }] each:^(Person *person) {
    [person delete];
}];
```
#### Mapping

The most of the time, your JSON web service returns keys like `first_name`, `last_name`, etc. <br/>
Your ObjC implementation has camelCased properties - `firstName`, `lastName`.<br/>

Since v1.2, camel case is supported automatically - you don't have to do nothing! Otherwise, if you have more complex mapping, here's how you do it:

``` objc
// just override - mappings in your NSManagedObject subclass
// this method is called just once, so you don't have to do any caching / singletons
@implementation Person

- (NSDictionary *)mappings {
  return @{ 
      @"id": @"remoteID",
      @"mmbr": @"isMember",
      // you can also map relationships, and initialize your graph from a single line
      @"employees": @{
          @"class": [Person class]
      },
      @"cars": @{
          @"key": "vehicles",
          @"class": [Vehicle class]
      }
  };
  // first_name => firstName is automatically handled
}

@end
```
#### Roadmap

- NSIncrementalStore support
- In memory store support
