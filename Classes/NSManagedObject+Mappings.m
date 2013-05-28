//
//  NSManagedObject+Mappings.m
//  CORE
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright (c) 2013 Clinically Relevant. All rights reserved.
//

#import "NSManagedObject+Mappings.h"
#import <objc/runtime.h>

static char cachedKeysKey;

@implementation NSManagedObject (Mappings)



+ (void)initialize {
    objc_setAssociatedObject(self, &cachedKeysKey, @{}.mutableCopy, OBJC_ASSOCIATION_RETAIN);
}

- (id)keyForRemoteKey:(id)key {
    
    if (self.cachedMappings[key])
        return self.cachedMappings[key];
    
    [self.cachedMappings setValuesForKeysWithDictionary:[[self class] mappings][key]];
    return self.cachedMappings[key] ?: key;
}

//- (void)cacheKey:(NSString *)key {
//    
//    // TODO: add responds to selector
//}

#pragma mark - Abstract

+ (NSDictionary *)mappings {
    return nil;
}


#pragma mark - Private

- (NSDictionary *)cachedMappings {
    return objc_getAssociatedObject(self, &cachedKeysKey);
}


@end
