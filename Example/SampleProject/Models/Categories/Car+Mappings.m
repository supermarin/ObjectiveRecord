//
//  Car+Mappings.m
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import "Car+Mappings.h"
#import "Person+Mappings.h"

@implementation Car (Mappings)

+ (NSDictionary *)mappings {
    return @{
        @"hp": @"horsePower",
        @"owner": @{
            @"class": [Person class]
        }
    };
}

@end
