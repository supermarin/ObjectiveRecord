//
//  Car.h
//  SampleProject
//
//  Created by Marin Usalj on 12/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InsuranceCompany, Person;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSNumber * horsePower;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) Person *owner;
@property (nonatomic, retain) InsuranceCompany *insuranceCompany;

@end
