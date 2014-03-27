//
//  InsuranceCompany+Mappings.m
//  SampleProject
//
//  Created by Marin Usalj on 12/3/13.
//
//

#import "InsuranceCompany+Mappings.h"
#import "Person.h"

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
