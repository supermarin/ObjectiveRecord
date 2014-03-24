#import "Person+Mappings.h"

#import "Car+Mappings.h"

@implementation Person (Mappings)

+ (NSString *)primaryKey {
    return @"remoteID";
}

+ (NSDictionary *)mappings {
    return @{
         @"id"       : [self primaryKey],
         @"employees": @{ @"class": [Person class] },
         @"cars"     : @{ @"class": [Car class] },
         @"manager"  : @{ @"class": [Person class] }
    };
}

@end
