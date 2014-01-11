//
//  Car+Mappings.m
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import "Car+Mappings.h"
#import "Person+Mappings.h"
#import "InsuranceCompany.h"

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
            @"transform": ^id(NSDictionary *value, NSManagedObjectContext *context) {
                InsuranceCompany * company = [InsuranceCompany findOrCreate:@{@"remoteID": value[@"id"] ?: value[@"remoteID"]} inContext:context];
                [company update:value];
                return company;
            }
        }
    };
}

@end
