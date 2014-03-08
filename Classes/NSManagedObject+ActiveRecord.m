//
//  NSManagedObject+ActiveRecord.m
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

#import "NSManagedObject+ActiveRecord.h"
#import "ObjectiveSugar.h"
#import "ObjectiveRelation.h"

@implementation NSManagedObjectContext (ActiveRecord)

+ (NSManagedObjectContext *)defaultContext {
    return [[CoreDataManager sharedManager] managedObjectContext];
}

@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - Finders

+ (instancetype)findOrCreate:(NSDictionary *)properties {
    return [[self all] findOrCreate:properties];
}

+ (instancetype)find:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    ObjectiveRelation *relation = [[self all] where:condition arguments:va_arguments];
    va_end(va_arguments);

    return [relation first];
}

+ (id)where:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    ObjectiveRelation *relation = [[self all] where:condition arguments:va_arguments];
    va_end(va_arguments);

    return relation;
}

+ (id)order:(id)order {
    return [[self all] order:order];
}

+ (id)reverseOrder {
    return [[self all] reverseOrder];
}

+ (id)limit:(NSUInteger)limit {
    return [[self all] limit:limit];
}

+ (id)offset:(NSUInteger)offset {
    return [[self all] offset:offset];
}

+ (id)inContext:(NSManagedObjectContext *)context {
    return [[self all] inContext:context];
}

+ (id)all {
    return [ObjectiveRelation relationWithEntity:[self class]];
}

+ (instancetype)first {
    return [[self all] first];
}

+ (instancetype)last {
    return [[self all] last];
}

+ (NSUInteger)count {
    return [[self all] count];
}

#pragma mark - Creation / Deletion

+ (id)create {
    return [[self all] create];
}

+ (id)create:(NSDictionary *)attributes {
    return [[self all] create:attributes];
}

- (void)update:(NSDictionary *)attributes {
    if (attributes == nil || (id)attributes == [NSNull null]) return;

    [attributes each:^(id key, id value) {
        id remoteKey = [self.class keyForRemoteKey:key];

        if ([remoteKey isKindOfClass:[NSString class]])
            [self setSafeValue:value forKey:remoteKey];
        else
            [self hydrateObject:value ofClass:remoteKey[@"class"] forKey:remoteKey[@"key"] ?: key];
    }];
}

- (BOOL)save {
    return [self saveTheContext];
}

+ (void)deleteAll {
    [[self all] deleteAll];
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}

#pragma mark - Naming

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

#pragma mark - Private

- (BOOL)saveTheContext {
    if (self.managedObjectContext == nil ||
        ![self.managedObjectContext hasChanges]) return YES;

    NSError *error = nil;
    BOOL save = [self.managedObjectContext save:&error];

    if (!save || error) {
        NSLog(@"Unresolved error in saving context for entity:\n%@!\nError: %@", self, error);
        return NO;
    }

    return YES;
}

- (void)hydrateObject:(id)properties ofClass:(Class)class forKey:(NSString *)key {
    [self setSafeValue:[self objectOrSetOfObjectsFromValue:properties ofClass:class]
                forKey:key];
}

- (id)objectOrSetOfObjectsFromValue:(id)value ofClass:(Class)class {
    if ([value isKindOfClass:[NSDictionary class]])
        return [[class inContext:self.managedObjectContext] findOrCreate:value];
    
    else if ([value isKindOfClass:[NSArray class]])
        return [NSSet setWithArray:[value map:^id(NSDictionary *dict) {
            return [[class inContext:self.managedObjectContext] findOrCreate:dict];
        }]];
    else
        return [[class inContext:self.managedObjectContext] findOrCreate:@{ [class primaryKey]: value }];
}

- (void)setSafeValue:(id)value forKey:(id)key {

    if (value == nil || value == [NSNull null]) {
        [self setValue:nil forKey:key];
        return;
    }

    NSDictionary *attributes = [[self entity] attributesByName];
    NSAttributeType attributeType = [[attributes objectForKey:key] attributeType];

    if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]]))
        value = [value stringValue];

    else if ([value isKindOfClass:[NSString class]]) {

        if ([self isIntegerAttributeType:attributeType])
            value = [NSNumber numberWithInteger:[value integerValue]];

        else if (attributeType == NSBooleanAttributeType)
            value = [NSNumber numberWithBool:[value boolValue]];

        else if (attributeType == NSFloatAttributeType)
            value = [NSNumber numberWithDouble:[value doubleValue]];

        else if (attributeType == NSDateAttributeType)
            value = [self.defaultFormatter dateFromString:value];
    }

    [self setValue:value forKey:key];
}

- (BOOL)isIntegerAttributeType:(NSAttributeType)attributeType {
    return (attributeType == NSInteger16AttributeType) ||
           (attributeType == NSInteger32AttributeType) ||
           (attributeType == NSInteger64AttributeType);
}

#pragma mark - Date Formatting

- (NSDateFormatter *)defaultFormatter {
    static NSDateFormatter *sharedFormatter;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        [sharedFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    });

    return sharedFormatter;
}

@end
