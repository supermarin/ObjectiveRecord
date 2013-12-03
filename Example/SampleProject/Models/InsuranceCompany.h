//
//  InsuranceCompany.h
//  SampleProject
//
//  Created by Marin Usalj on 12/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car;

@interface InsuranceCompany : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSSet *cars;
@end

@interface InsuranceCompany (CoreDataGeneratedAccessors)

- (void)addCarsObject:(Car *)value;
- (void)removeCarsObject:(Car *)value;
- (void)addCars:(NSSet *)values;
- (void)removeCars:(NSSet *)values;

@end
