//
//  Person+Mappings.m
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import "Person+Mappings.h"
#import "Car+Mappings.h"

@implementation Person (Mappings)

- (NSDictionary *)mappings {
    return @{
             @"cars" : @{
                     @"class": [Car class]
                     }
             };
}

@end
