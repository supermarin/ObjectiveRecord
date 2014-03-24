#import "Car+Mappings.h"

#import "Person+Mappings.h"
#import "InsuranceCompany+Mappings.h"

@implementation Car (Mappings)

+ (NSDictionary *)mappings {
    return @{
        @"hp": @"horsePower",
        @"owner": @{
            @"class": [Person class]
        },
        @"insurance_id": @{
            @"key": @"insuranceCompany",
            @"class": [InsuranceCompany class]
        },
        @"insurance_company": @{
                @"key": @"insuranceCompany",
                @"class": [InsuranceCompany class]
                }

    };
}

@end
