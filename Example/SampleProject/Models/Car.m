//
//  Car.m
//  SampleProject
//
//  Created by Marin Usalj on 5/28/13.
//
//

#import "Car.h"


@implementation Car

@dynamic make;
@dynamic horsePower;

- (NSDictionary *)mappings {
    return @{ @"hp": @"horsePower" };
}

@end
