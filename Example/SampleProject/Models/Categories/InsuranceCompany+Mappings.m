#import "InsuranceCompany+Mappings.h"

#import "Person+Mappings.h"

@implementation InsuranceCompany (Mappings)

+ (id)primaryKey {
    return @"remoteID";
}

+ (NSDictionary *)mappings {
    return @{
             @"id" : [self primaryKey],
             @"owner_id" : @{
                     @"key"   : @"owner",
                     @"class" : [Person class] },
             @"owner" : @{
                     @"class" : [Person class] }
             };
}

@end
