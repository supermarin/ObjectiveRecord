#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car, Person;

@interface InsuranceCompany : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSSet *cars;
@property (nonatomic, retain) Person *owner;

@end
