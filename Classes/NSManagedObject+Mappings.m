// NSManagedObject+Mappings.m
//
// Copyright (c) 2014 Marin Usalj <http://supermar.in>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ObjectiveSugar.h"

#import "NSManagedObject+Mappings.h"

#import "NSManagedObject+ActiveRecord.h"

@implementation NSManagedObject (Mappings)

+ (NSString *)keyForRemoteKey:(NSString *)remoteKey inContext:(NSManagedObjectContext *)context {
    if ([self cachedMappings][remoteKey])
        return [self cachedMappings][remoteKey][@"key"];

    NSString *camelCasedProperty = [[remoteKey camelCase] stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[remoteKey substringWithRange:NSMakeRange(0, 1)] lowercaseString]];

    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];

    if ([entity propertiesByName][camelCasedProperty]) {
        [self cacheKey:camelCasedProperty forRemoteKey:camelCasedProperty];
        return camelCasedProperty;
    }

    [self cacheKey:remoteKey forRemoteKey:remoteKey];
    return remoteKey;
}

+ (id)transformValue:(id)value forRemoteKey:(NSString *)remoteKey inContext:(NSManagedObjectContext *)context {
    Class class = [self cachedMappings][remoteKey][@"class"];
    if (class)
        return [self objectOrSetOfObjectsFromValue:value ofClass:class inContext:context];

    return value;
}

+ (NSDictionary *)transformProperties:(NSDictionary *)properties withContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];

    NSDictionary *attributes = [entity attributesByName];
    NSDictionary *relationships = [entity relationshipsByName];

    NSMutableDictionary *transformed = [NSMutableDictionary dictionaryWithCapacity:[properties count]];

    for (NSString *key in properties) {
        NSString *localKey = [self keyForRemoteKey:key inContext:context];
        if (attributes[localKey] || relationships[localKey]) {
            transformed[localKey] = [[self class] transformValue:properties[key] forRemoteKey:key inContext:context];
        } else {
#if DEBUG
            NSLog(@"Discarding key ('%@') from properties on class ('%@'): no attribute or relationship found",
                  key, [self class]);
#endif
        }
    }

    return transformed;
}

#pragma mark - Private

+ (id)objectOrSetOfObjectsFromValue:(id)value ofClass:class inContext:(NSManagedObjectContext *)context {
    if ([value isKindOfClass:class])
        return value;

    if ([value isKindOfClass:[NSDictionary class]])
        return [[class inContext:context] findOrCreate:value];

    if ([value isKindOfClass:[NSArray class]])
        return [NSSet setWithArray:[value map:^id(id object) {
            return [self objectOrSetOfObjectsFromValue:object ofClass:class inContext:context];
        }]];

    return [[class inContext:context] findOrCreate:@{[class primaryKey]: value}];
}

+ (NSMutableDictionary *)cachedMappings {
    NSMutableDictionary *cachedMappings = [self sharedMappings][[self class]];
    if (!cachedMappings) {
        cachedMappings = [self sharedMappings][(id<NSCopying>)[self class]] = [NSMutableDictionary new];

        [[self mappings] each:^(id key, id value) {
            if ([value isKindOfClass:[NSString class]])
                [self cacheKey:value forRemoteKey:key];

            else {
                cachedMappings[key] = value;
                [self cacheKey:key forRemoteKey:key];
            }
        }];
    }
    return cachedMappings;
}

+ (NSMutableDictionary *)sharedMappings {
    static NSMutableDictionary *sharedMappings;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        sharedMappings = [NSMutableDictionary new];
    });
    return sharedMappings;
}

+ (void)cacheKey:(NSString *)key forRemoteKey:(NSString *)remoteKey {
    NSMutableDictionary *mapping = [[self cachedMappings][remoteKey] mutableCopy] ?: [NSMutableDictionary new];
    if (mapping[@"key"] == nil) mapping[@"key"] = key;
    [self cachedMappings][remoteKey] = mapping;
}

#pragma mark - Abstract

+ (NSDictionary *)mappings {
    return nil;
}

+ (id)primaryKey {
    @throw [NSException exceptionWithName:NSStringWithFormat(@"Primary key undefined in %@", self.class)
                                   reason:NSStringWithFormat(@"You need to override %@ +primaryKey if you want to support automatic creation with only object ID",
                                                             self.class)
                                 userInfo:nil];
}

@end
