# ObjectiveRecord [![CocoaPod][pd-bdg]][pd] [![Build Status][ci-bdg]][ci]

[pd-bdg]: https://img.shields.io/cocoapods/v/ObjectiveRecord.svg
[pd]: http://cocoadocs.org/docsets/ObjectiveRecord
[ci-bdg]: https://travis-ci.org/supermarin/ObjectiveRecord.svg
[ci]: https://travis-ci.org/supermarin/ObjectiveRecord

Objective Record is a lightweight ActiveRecord way of managing Core Data
objects. If you've used Ruby on Rails before, it might sound
familiar.

No AppDelegate code required. It's fully tested with
[Kiwi](https://github.com/allending/Kiwi).

#### Usage

1. Install with [CocoaPods](http://cocoapods.org) or clone
2. `#import "ObjectiveRecord.h"` in your model or .pch file.

#### Create / Save / Delete

``` objc
Person *john = [Person create];
john.name = @"John";
[john save];
[john delete];

[Person create:@{ 
    @"name" : @"John",
    @"age" : @12, 
    @"member" : @NO 
}];
```

#### Finders

``` objc
// all Person entities from the database
NSArray *people = [Person all];

// Person entities with name John
NSArray *johns = [Person where:@"name == 'John'"];

// And of course, John Doe!
Person *johnDoe = [Person find:@"name == %@ AND surname == %@", @"John", @"Doe"];

// Members over 18 from NY
NSArray *people = [Person where:@{ 
                      @"age" : @18,
                      @"member" : @YES,
                      @"state" : @"NY"
                  }];

// You can even write your own NSPredicate
NSPredicate *membersPredicate = [NSPredicate  predicateWithBlock:^BOOL(Person *person, NSDictionary *bindings) {
    return person.isMember == YES;
}];
NSArray *members = [Person where:membersPredicate];
```

#### Order and Limit

``` objc
// People by their last name ascending
NSArray *sortedPeople = [Person allWithOrder:@"surname"];

// People named John by their last name Z to A
NSArray *reversedPeople = [Person where:@{@"name" : @"John"} 
                                  order:@{@"surname" : @"DESC"}];

// You can use NSSortDescriptor too
NSArray *people = [Person allWithOrder:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

// And multiple orderings with any of the above
NSArray *morePeople = [Person allWithOrder:@"surname ASC, name DESC"];

// Just the first 5 people named John sorted by last name
NSArray *fivePeople = [Person where:@"name == 'John'"
                              order:@{@"surname" : @"ASC"}
                              limit:@(5)];
```

#### Aggregation

``` objc
// count all Person entities
NSUInteger personCount = [Person count];

// count people named John
NSUInteger johnCount = [Person countWhere:@"name == 'John'"];
```

#### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
newContext.persistentStoreCoordinator = [[CoreDataManager instance] persistentStoreCoordinator];

Person *john = [Person createInContext:newContext];
Person *john = [Person find:@"name == 'John'" inContext:newContext];
NSArray *people = [Person allInContext:newContext];
```

#### Custom CoreData model or .sqlite database
If you've added the Core Data manually, you can change the custom model and database name on CoreDataManager
``` objc
[CoreDataManager sharedManager].modelName = @"MyModelName";
[CoreDataManager sharedManager].databaseName = @"custom_database_name";
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
[[Person where: @{ @"member" : @NO }] each:^(Person *person) {
    [person delete];
}];
```
#### Mapping

The most of the time, your JSON web service returns keys like `first_name`, `last_name`, etc. <br/>
Your ObjC implementation has camelCased properties - `firstName`, `lastName`.<br/>

Since v1.2, camel case is supported automatically - you don't have to do anything! Otherwise, if you have more complex mapping, here's how you do it:

``` objc
// just override +mappings in your NSManagedObject subclass
// this method is called just once, so you don't have to do any caching / singletons
@implementation Person

+ (NSDictionary *)mappings {
  return @{ 
      @"id": @"remoteID",
      @"mmbr": @"isMember",
      // you can also map relationships, and initialize your graph from a single line
      @"employees": @{
          @"class": [Person class]
      },
      @"cars": @{
          @"key": @"vehicles",
          @"class": [Vehicle class]
      }
  };
  // first_name => firstName is automatically handled
}

@end
```

#### Testing

ObjectiveRecord supports CoreData's in-memory store. In any place, before your tests start running, it's enough to call
``` objc
[[CoreDataManager sharedManager] useInMemoryStore];
```

#### Roadmap

- NSIncrementalStore support

## License

ObjectiveRecord is available under the MIT license. See the LICENSE file
for more information.
