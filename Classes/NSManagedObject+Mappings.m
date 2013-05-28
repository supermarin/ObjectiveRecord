//
//  NSManagedObject+Mappings.m
//  CORE
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright (c) 2013 Clinically Relevant. All rights reserved.
//

#import "NSManagedObject+Mappings.h"
#import "ObjectiveSugar.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary(Mappings)

+ (instancetype)sharedMappings {
    static NSMutableDictionary *singleton;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

@end


@implementation NSManagedObject (Mappings)

- (id)keyForRemoteKey:(NSString *)remoteKey {
    
    if (self.cachedMappings[remoteKey])
        return self.cachedMappings[remoteKey];
    
    NSString *camelCasedProperty = [remoteKey.camelCase stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                withString:[[remoteKey substringWithRange:NSMakeRange(0, 1)] lowercaseString]];
    
    if ([self respondsToSelector:NSSelectorFromString(camelCasedProperty)]) {
        self.cachedMappings[remoteKey] = camelCasedProperty;
        return camelCasedProperty;
    }

    [self cachedMappings][remoteKey] = remoteKey;
    return remoteKey;
}


#pragma mark - Private

- (NSMutableDictionary *)cachedMappings {
    NSMutableDictionary *mappings = [NSMutableDictionary sharedMappings][self.class];

    if (!mappings) {
        mappings = [self mappings].mutableCopy ?: @{}.mutableCopy;
        [NSMutableDictionary sharedMappings][(id<NSCopying>)self.class] = mappings;
    }
    
    return mappings;
}


#pragma mark - Abstract

- (NSDictionary *)mappings {
    return nil;
}


@end
