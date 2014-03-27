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

@implementation NSManagedObjectContext (ActiveRecord)

+ (NSManagedObjectContext *)defaultContext {
    return [[CoreDataManager sharedManager] managedObjectContext];
}

@end

@implementation NSObject(null)

- (BOOL)exists {
    return self && self != [NSNull null];
}

@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - Finders

+ (NSArray *)all {
    return [self allInContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allWithOrder:(id)order {
    return [self allInContext:[NSManagedObjectContext defaultContext] order:order];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    return [self allInContext:context order:nil];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order {
    return [self fetchWithCondition:nil inContext:context withOrder:order fetchLimit:nil];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties {
    return [self findOrCreate:properties inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context {
    NSDictionary *transformed = [[self class] transformProperties:properties withContext:context];

    NSManagedObject *existing = [self where:transformed inContext:context].first;
    return existing ?: [self create:transformed inContext:context];
}

+ (instancetype)find:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    NSPredicate *predicate = [self predicateFromObject:condition arguments:va_arguments];
    va_end(va_arguments);

    return [self find:predicate inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context {
    return [self where:condition inContext:context limit:@1].first;
}

+ (NSArray *)where:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    NSPredicate *predicate = [self predicateFromObject:condition arguments:va_arguments];
    va_end(va_arguments);

    return [self where:predicate inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition order:(id)order {
    return [self where:condition inContext:[NSManagedObjectContext defaultContext] order:order];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit {
    return [self where:condition inContext:[NSManagedObjectContext defaultContext] limit:limit];
}

+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit {
    return [self where:condition inContext:[NSManagedObjectContext defaultContext] order:order limit:limit];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context {
    return [self where:condition inContext:context order:nil limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order {
    return [self where:condition inContext:context order:order limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit {
    return [self where:condition inContext:context order:nil limit:limit];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit {
    return [self fetchWithCondition:condition inContext:context withOrder:order fetchLimit:limit];
}

#pragma mark - Aggregation

+ (NSUInteger)count {
    return [self countInContext:[NSManagedObjectContext defaultContext]];
}

+ (NSUInteger)countWhere:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    NSPredicate *predicate = [self predicateFromObject:condition arguments:va_arguments];
    va_end(va_arguments);

    return [self countWhere:predicate inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context {
    return [self countForFetchWithPredicate:nil inContext:context];
}

+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [self predicateFromObject:condition];

    return [self countForFetchWithPredicate:predicate inContext:context];
}

#pragma mark - Creation / Deletion

+ (id)create {
    return [self createInContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes {
    return [self create:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    unless([attributes exists]) return nil;

    NSManagedObject *newEntity = [self createInContext:context];
    [newEntity update:attributes];

    return newEntity;
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

- (void)update:(NSDictionary *)attributes {
    unless([attributes exists]) return;

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

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}

+ (void)deleteAll {
    [self deleteAllInContext:[NSManagedObjectContext defaultContext]];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context {
    [[self allInContext:context] each:^(id object) {
        [object delete];
    }];
}

#pragma mark - Naming

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

#pragma mark - Private

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

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict {
    NSArray *subpredicates = [dict map:^(NSString *key, id value) {
        return [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    }];

    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition {
    return [self predicateFromObject:condition arguments:NULL];
}

+ (NSPredicate *)predicateFromObject:(id)condition arguments:(va_list)arguments {
    if ([condition isKindOfClass:[NSPredicate class]])
        return condition;

    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition arguments:arguments];

    if ([condition isKindOfClass:[NSDictionary class]])
        return [self predicateFromDictionary:condition];

    return nil;
}

+ (NSSortDescriptor *)sortDescriptorFromDictionary:(NSDictionary *)dict {
    BOOL isAscending = ![[dict.allValues.first uppercaseString] isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:dict.allKeys.first
                                         ascending:isAscending];
}

+ (NSSortDescriptor *)sortDescriptorFromString:(NSString *)order {
    NSArray *components = [order split];

    NSString *key = [components firstObject];
    NSString *value = [components count] > 1 ? components[1] : @"ASC";

    return [self sortDescriptorFromDictionary:@{key: value}];

}

+ (NSSortDescriptor *)sortDescriptorFromObject:(id)order {
    if ([order isKindOfClass:[NSSortDescriptor class]])
        return order;

    if ([order isKindOfClass:[NSString class]])
        return [self sortDescriptorFromString:order];

    if ([order isKindOfClass:[NSDictionary class]])
        return [self sortDescriptorFromDictionary:order];

    return nil;
}

+ (NSArray *)sortDescriptorsFromObject:(id)order {
    if ([order isKindOfClass:[NSString class]])
        order = [order componentsSeparatedByString:@","];

    if ([order isKindOfClass:[NSArray class]])
        return [order map:^id (id object) {
            return [self sortDescriptorFromObject:object];
        }];

    return @[[self sortDescriptorFromObject:order]];
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithCondition:(id)condition
                      inContext:(NSManagedObjectContext *)context
                      withOrder:(id)order
                     fetchLimit:(NSNumber *)fetchLimit {

    NSFetchRequest *request = [self createFetchRequestInContext:context];

    if (condition)
        [request setPredicate:[self predicateFromObject:condition]];

    if (order)
        [request setSortDescriptors:[self sortDescriptorsFromObject:order]];

    if (fetchLimit)
        [request setFetchLimit:[fetchLimit integerValue]];

    return [context executeFetchRequest:request error:nil];
}

+ (NSUInteger)countForFetchWithPredicate:(NSPredicate *)predicate
                               inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];

    return [context countForFetchRequest:request error:nil];
}

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

@end
