//
//  Person.h
//  SampleProject
//
//  Created by Ignacio Romero Z. on 8/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car, InsuranceCompany, Person;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * anniversary;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isMember;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * lifeSavings;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSSet *cars;
@property (nonatomic, retain) NSSet *employees;
@property (nonatomic, retain) InsuranceCompany *insuranceCompany;
@property (nonatomic, retain) Person *manager;
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
