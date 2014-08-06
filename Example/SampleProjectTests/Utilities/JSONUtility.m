//
//  JSONUtility.m
//  SampleProject
//
//  Created by Ignacio Romero Z. on 8/6/14.
//
//

#import "JSONUtility.h"

@implementation JSONUtility

id JSON(NSString *resource) {
    return JSONFromBundle(resource, [NSBundle mainBundle]);
}

id JSONFromBundle(NSString *resource, NSBundle *bundle) {
    NSError *error = nil;
    NSString *path = [bundle pathForResource:resource ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (!data) {
        NSLog(@"Failed with json at path : %@", path);
        return nil;
    }
    
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions|NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
        return nil;
    }
    
    NSLog(@"Parsed %@ successfuly : %@", resource, JSON);
    
    return JSON;
}

@end
