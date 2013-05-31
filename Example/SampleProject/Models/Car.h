//
//  Car.h
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSNumber * horsePower;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) Person *owner;

@end
