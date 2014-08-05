//
//  InsuranceCompany.h
//  SampleProject
//
//  Created by Ignacio Romero Z. on 8/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car, Person;

@interface InsuranceCompany : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSSet *cars;
@property (nonatomic, retain) Person *owner;
@end

@interface InsuranceCompany (CoreDataGeneratedAccessors)

- (void)addCarsObject:(Car *)value;
- (void)removeCarsObject:(Car *)value;
- (void)addCars:(NSSet *)values;
- (void)removeCars:(NSSet *)values;

@end
