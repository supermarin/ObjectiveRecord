#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car, InsuranceCompany;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * anniversary;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isMember;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSNumber * savings;
@property (nonatomic, retain) NSSet *cars;
@property (nonatomic, retain) InsuranceCompany *insuranceCompany;
@property (nonatomic, retain) ObjectiveRelation *employees;
@property (nonatomic, retain) Person *manager;

@end
