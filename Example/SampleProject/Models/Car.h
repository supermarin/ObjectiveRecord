#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InsuranceCompany, Person;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSNumber *horsePower;
@property (nonatomic, retain) NSString *make;
@property (nonatomic, retain) Person *owner;
@property (nonatomic, retain) InsuranceCompany *insuranceCompany;

@end
