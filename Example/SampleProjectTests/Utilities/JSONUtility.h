//
//  JSONUtility.h
//  SampleProject
//
//  Created by Ignacio Romero Z. on 8/6/14.
//
//

#import <Foundation/Foundation.h>

@interface JSONUtility : NSObject

id JSON(NSString *resource);
id JSONFromBundle(NSString *resource, NSBundle *bundle);

@end
