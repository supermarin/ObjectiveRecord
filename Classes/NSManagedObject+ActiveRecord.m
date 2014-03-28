// NSManagedObject+ActiveRecord.m
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

#import "NSManagedObject+ActiveRecord.h"
#import "ObjectiveSugar.h"
#import "ObjectiveRelation.h"

#import <objc/runtime.h>

@implementation NSManagedObjectContext (ActiveRecord)

+ (NSManagedObjectContext *)defaultContext {
    return [[CoreDataManager sharedManager] managedObjectContext];
}

@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - Fetch request building

+ (ObjectiveRelation *)all {
    return [ObjectiveRelation relationWithManagedObjectClass:self];
}

+ (ObjectiveRelation *)where:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    ObjectiveRelation *relation = [[self all] where:condition arguments:va_arguments];
    va_end(va_arguments);

    return relation;
}

+ (ObjectiveRelation *)order:(id)order {
    return [[self all] order:order];
}

+ (ObjectiveRelation *)reverseOrder {
    return [[self all] reverseOrder];
}

+ (ObjectiveRelation *)limit:(NSUInteger)limit {
    return [[self all] limit:limit];
}

+ (ObjectiveRelation *)offset:(NSUInteger)offset {
    return [[self all] offset:offset];
}

+ (ObjectiveRelation *)inContext:(NSManagedObjectContext *)context {
    return [[self all] inContext:context];
}

#pragma mark Counting

+ (NSUInteger)count {
    return [[self all] count];
}

#pragma mark Plucking

+ (instancetype)firstObject {
    return [[self all] firstObject];
}

+ (instancetype)lastObject {
    return [[self all] lastObject];
}

+ (instancetype)find:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    ObjectiveRelation *relation = [[self all] where:condition arguments:va_arguments];
    va_end(va_arguments);

    return [relation firstObject];
}

#pragma mark - Manipulating entities

+ (instancetype)findOrCreate:(NSDictionary *)properties {
    return [[self all] findOrCreate:properties];
}

+ (instancetype)create {
    return [[self all] create];
}

+ (instancetype)create:(NSDictionary *)attributes {
    return [[self all] create:attributes];
}

+ (void)updateAll:(NSDictionary *)attributes {
    [[self all] updateAll:attributes];
}

- (void)update:(NSDictionary *)attributes {
    if (attributes == nil || (id)attributes == [NSNull null]) return;

    NSDictionary *transformed = [[self class] transformProperties:attributes withContext:self.managedObjectContext];

    for (NSString *key in transformed) [self willChangeValueForKey:key];
    [transformed each:^(NSString *key, id value) {
        [self setSafeValue:value forKey:key];
    }];
    for (NSString *key in transformed) [self didChangeValueForKey:key];
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

#pragma mark - Relations

- (id)relationWithName:(NSString *)name {
    return [ObjectiveRelation relationWithManagedObject:self relationship:name];
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

- (void)setSafeValue:(id)value forKey:(NSString *)key {
    if (value == nil || value == [NSNull null]) {
        [self setNilValueForKey:key];
        return;
    }

    NSAttributeDescription *attribute = [[self entity] attributesByName][key];
    NSAttributeType attributeType = [attribute attributeType];

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

    [self setPrimitiveValue:value forKey:key];
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

#pragma mark - Dynamic relationships

/**
 CoreData generates its dynamic properties using +resolveInstanceMethod. We swizzle it in order to return ObjectiveRelation instances, instead, for id-type, to-many relationships (default properties that are declared NSSet will not be affected).
 */
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)self);

        Method originalMethod = class_getInstanceMethod(class, @selector(resolveInstanceMethod:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(or_resolveInstanceMethod:));

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

+ (BOOL)or_resolveInstanceMethod:(SEL)sel {
    BOOL resolved = [self or_resolveInstanceMethod:sel];

    objc_property_t property = class_getProperty(self, sel_getName(sel));
    char * dynamic = property_copyAttributeValue(property, "D");
    char * type = property_copyAttributeValue(property, "T");

    if (resolved && dynamic && strcmp(type, "@\"ObjectiveRelation\"") == 0) {
        Method originalMethod = class_getInstanceMethod(self, sel);

        IMP originalIMP = method_getImplementation(originalMethod);
        IMP dynamicIMP = imp_implementationWithBlock(^(id self) {
            return [self relationWithName:NSStringFromSelector(sel)] ?: originalIMP(self, sel);
        });

        method_setImplementation(originalMethod, dynamicIMP);
        return YES;
    }

    return resolved;
}

@end
