
//  Person+Mappings.m
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import "Person+Mappings.h"
#import "Car+Mappings.h"

@implementation Person (Mappings)

+ (NSDictionary *)mappings {
    return @{
         @"employees": @{ @"class": [Person class] },
         @"cars"     : @{ @"class": [Car class] },
         @"manager"  : @{ @"class": [Person class] }
    };
}

@end
