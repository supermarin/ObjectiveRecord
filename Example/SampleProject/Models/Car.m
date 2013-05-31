//
//  Car.m
//  SampleProject
//
//  Created by Marin Usalj on 5/31/13.
//
//

#import "Car.h"
#import "Person.h"


@implementation Car

@dynamic horsePower;
@dynamic make;
@dynamic owner;

- (NSDictionary *)mappings {
    return @{ @"hp": @"horsePower" };
}

@end
