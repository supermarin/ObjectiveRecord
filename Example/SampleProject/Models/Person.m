//
//  Person.m
//  SampleProject
//
//  Created by Marin Usalj on 5/28/13.
//
//

#import "Person.h"

@implementation Person

@dynamic age;
@dynamic isMember;
@dynamic firstName;
@dynamic lastName;

+ (NSDictionary *)mappings {
    return @{
        @"first_name": @"firstName",
        @"last_name": @"lastName"
    };
}

@end
