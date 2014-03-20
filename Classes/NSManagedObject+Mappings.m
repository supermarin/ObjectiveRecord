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

#import "NSManagedObject+Mappings.h"
#import "NSManagedObject+ActiveRecord.h"
#import "ObjectiveSugar.h"


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
