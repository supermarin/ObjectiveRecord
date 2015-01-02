//
//  Car.h
//  SampleProject
//
//  Created by Ignacio Romero Z. on 8/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InsuranceCompany, Person;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSNumber * horsePower;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) InsuranceCompany *insuranceCompany;
@property (nonatomic, retain) Person *owner;

@end
