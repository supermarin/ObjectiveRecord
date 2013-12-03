//
//  NSManagedObject+Mappings.m
//  CORE
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright (c) 2013 Clinically Relevant. All rights reserved.
//

#import "NSManagedObject+Mappings.h"
#import "NSManagedObject+ActiveRecord.h"
#import "ObjectiveSugar.h"
#import <objc/runtime.h>


@implementation NSManagedObject (Mappings)

+ (id)keyForRemoteKey:(NSString *)remoteKey {
    
    if (self.cachedMappings[remoteKey])
        return self.cachedMappings[remoteKey];
    
    NSString *camelCasedProperty = [remoteKey.camelCase stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                withString:[[remoteKey substringWithRange:NSMakeRange(0, 1)] lowercaseString]];

    NSEntityDescription *desc = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    
    if ([desc propertiesByName][camelCasedProperty]) {
        self.cachedMappings[remoteKey] = camelCasedProperty;
        return camelCasedProperty;
    }

    [self cachedMappings][remoteKey] = remoteKey;
    return remoteKey;
}

#pragma mark - Private

+ (NSMutableDictionary *)cachedMappings {
    NSMutableDictionary *mappingsForClass = [NSManagedObject sharedMappings][self.class];

    if (!mappingsForClass) {
        mappingsForClass = [self mappings].mutableCopy ?: @{}.mutableCopy;
        [NSManagedObject sharedMappings][(id<NSCopying>)self.class] = mappingsForClass;
    }
    
    return mappingsForClass;
}

+ (NSMutableDictionary *)sharedMappings {
    static NSMutableDictionary *singleton;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = @{}.mutableCopy;
    });
    return singleton;
}


#pragma mark - Abstract

+ (NSDictionary *)mappings {
    return nil;
}

+ (id)primaryKey {
    @throw [NSException exceptionWithName:NSStringWithFormat(@"Primary key undefined in %@", self.class)
                                   reason:NSStringWithFormat(@"You need to override %@ +primaryKey if you want to support automatic creation with only object ID", self.class)
                                 userInfo:nil];
}

@end
