//
//  Person.h
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car, Person;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isMember;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *cars;
@property (nonatomic, retain) Person *manager;
@property (nonatomic, retain) NSSet *employees;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addCarsObject:(Car *)value;
- (void)removeCarsObject:(Car *)value;
- (void)addCars:(NSSet *)values;
- (void)removeCars:(NSSet *)values;

- (void)addEmployeesObject:(Person *)value;
- (void)removeEmployeesObject:(Person *)value;
- (void)addEmployees:(NSSet *)values;
- (void)removeEmployees:(NSSet *)values;

@end
