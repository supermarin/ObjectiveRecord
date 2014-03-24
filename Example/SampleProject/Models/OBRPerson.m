#import "OBRPerson.h"

@implementation OBRPerson

@dynamic name;
@dynamic surname;
@dynamic age;
@dynamic isMember;

+ (NSString *)entityName {
    return @"OtherPerson";
}

@end
