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
[Person create:dictionary];

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
If you've added the Core Data manually, you can change the custom model and database name in CoreDataManager.m
``` objc

static NSString *CUSTOM_MODEL_NAME = @"Database";
static NSString *CUSTOM_DATABASE_NAME = nil;
```

#### NSArray additions

``` objc
NSArray *array; // assume it's full of objects

[array each:^(id object) {
    
    NSLog(@"Object: %@", object); 
}];

[array eachWithIndex:^(id object, int index) {
    
    NSLog(@"Object: %@ idx: %i", object, index); 
}];

id object = array.first;
id object = array.last;
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

####ToDo
Try to make `where:(NSString *)condition` take va_args like NSLog().
That way you wouldn't have to use -stringWithFormat, and it would look cleaner.
