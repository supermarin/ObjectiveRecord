//
//  OBRPerson.m
//  SampleProject
//
//  Created by Elliot Neal on 22/05/2013.
//
//

#import "OBRPerson.h"


@implementation OBRPerson

@dynamic name;
@dynamic surname;
@dynamic age;
@dynamic isMember;


+ (NSString *)entityName {
    return @"OtherPerson";
}

@end
