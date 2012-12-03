## Intro
This is a lightweight ActiveRecord way of managing Core Data objects.
The syntax is borrowed from Ruby on Rails.<br>
And yeah, no AppDelegate code.
It's fully tested with [Kiwi](https://github.com/allending/Kiwi).

### Usage
1. Install with [CocoaPods](http://cocoapods.org) or clone
2. `#import "ObjectiveRecord.h"` in your model or .pch file.

#### Create / Save / Delete

``` objc
Person *john = [Person create];
john.name = @"John";
john.save;
john.delete;

NSDictionary *attributes; // assume it's populated with name = john, key = value,...
[Person create:attributes];
// the same thing 
[Person create:@{ @"name" : @"John", @"age" : @12, @"member" : @NO }]; // XCode >= 4.4
```

#### Finders

``` objc
NSArray *people = [Person all];
NSArray *johns = [Person where:@"name == 'John'"];
Person *johnDoe = [Person where:@"name == 'John' AND surname = 'Doe'"].first;

// XCode >= 4.4
NSArray *people = [Person where:@{ @"age" : @18 }];

NSArray *people = [Person where:@{ @"age" : @18,
                  @"member" : @YES,
                  @"state" : @"NY"
                  }];
```

### Custom ManagedObjectContext

``` objc
NSManagedObjectContext *newContext = [NSManagedObjectContext new];

Person *john = [Person createInContext:newContext];
Person *john = [Person where:@"name == 'John'" inContext:newContext].first;
NSArray *people = [Person allInContext:newContext];
```

### Custom CoreData model or .sqlite database
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
john.save;

// find / delete
[[Person where: @{ "member" : @NO }] each:^(Person *person) {
  
  [person delete];
}];
```

