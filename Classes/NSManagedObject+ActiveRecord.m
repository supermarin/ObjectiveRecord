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

@implementation NSObject(null)

- (BOOL)exists
{
    return self && self != [NSNull null];
}

@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - Finders

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    return [self allInContext:context order:nil];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order
{
    return [self fetchWithCondition:nil inContext:context withOrder:order fetchLimit:nil];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context
{
    NSDictionary *transformed = [[self class] transformProperties:properties withObject:nil context:context];

    NSManagedObject *existing = [self where:transformed inContext:context].first;
    return existing ?: [self create:transformed inContext:context];
}

+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self where:condition inContext:context limit:@1].first;
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self where:condition inContext:context order:nil limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order
{
    return [self where:condition inContext:context order:order limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit
{
    return [self where:condition inContext:context order:nil limit:limit];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit
{
    return [self fetchWithCondition:condition inContext:context withOrder:order fetchLimit:limit];
}

#pragma mark - Aggregation

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context
{
    return [self countForFetchWithPredicate:nil inContext:context];
}

+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [self predicateFromObject:condition];

    return [self countForFetchWithPredicate:predicate inContext:context];
}

#pragma mark - Creation

+ (id)createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    unless([attributes exists]) return nil;
    
    NSManagedObject *newEntity = [self createInContext:context];
    [newEntity update:attributes inContext:context];
    
    return newEntity;
}

+ (instancetype)updateOrCreate:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    NSString *localKey = [[self mappings] allKeysForObject:[self primaryKey]].first;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self primaryKey], attributes[localKey]];
    
    NSManagedObject *existing = [self where:predicate inContext:context].first;
    
    if (!existing) {
        return [self create:attributes inContext:context];
    }
    
    [existing update:attributes inContext:context];
    
    return existing;
}

- (void)update:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    unless([attributes exists]) return;

    NSDictionary *transformed = [[self class] transformProperties:attributes withObject:self context:context];

    for (NSString *key in transformed) {
        [self willChangeValueForKey:key];
    }
    
    [transformed each:^(NSString *key, id value) {
        [self setSafeValue:value forKey:key];
    }];
    
    for (NSString *key in transformed) {
        [self didChangeValueForKey:key];
    }
}

#pragma mark - Deletion

- (void)deleteInContext:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    [[self allInContext:context] each:^(id object) {
        [object deleteInContext:context];
    }];
}

#pragma mark - Saving

- (BOOL)saveInContext:(NSManagedObjectContext *)context
{
    if (context == nil ||
        ![context hasChanges]) return YES;
    
    NSError *error = nil;
    BOOL save = [context save:&error];
    
    if (!save || error) {
        NSLog(@"Unresolved error in saving context for entity:\n%@!\nError: %@", self, error);
        return NO;
    }
    
    return YES;
}

#pragma mark - Naming

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

#pragma mark - Private

+ (NSDictionary *)transformProperties:(NSDictionary *)properties withObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];

    NSDictionary *attributes = [entity attributesByName];
    NSDictionary *relationships = [entity relationshipsByName];

    NSMutableDictionary *transformed = [NSMutableDictionary dictionaryWithCapacity:[properties count]];

    for (NSString *key in properties) {
        NSString *localKey = [self keyForRemoteKey:key inContext:context];
        if (attributes[localKey] || relationships[localKey]) {
            id value = [[self class] transformValue:properties[key] forRemoteKey:key inContext:context];
            if (object) {
                id localValue = [object primitiveValueForKey:localKey];
                if ([localValue isEqual:value] || (localValue == nil && value == [NSNull null]))
                    continue;
            }
            transformed[localKey] = value;
        } else {
#if DEBUG
            NSLog(@"Discarding key ('%@') from properties on class ('%@'): no attribute or relationship found",
                  key, [self class]);
#endif
        }
    }
    
    for (NSString *attribute in [attributes allKeys]) {
        NSString *keypath = [self keyPathForRemoteKey:attribute];
        
        if (keypath) {
            id value = [properties valueForKeyPath:keypath];
            NSString *localKey = [self keyForRemoteKey:attribute inContext:context];
            if (!value || !localKey)
                continue;
            transformed[localKey] = value;
        }
    }

    return transformed;
}

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict
{
    NSArray *subpredicates = [dict map:^(NSString *key, id value) {
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            return (id)[NSPredicate predicateWithFormat:@"%@ IN %K", value, key];
        }
        else {
            return (id)[NSPredicate predicateWithFormat:@"%K = %@", key, value];
        }
    }];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition
{
    return [self predicateFromObject:condition arguments:NULL];
}

+ (NSPredicate *)predicateFromObject:(id)condition arguments:(va_list)arguments
{
    if ([condition isKindOfClass:[NSPredicate class]])
        return condition;

    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition arguments:arguments];

    if ([condition isKindOfClass:[NSDictionary class]])
        return [self predicateFromDictionary:condition];

    return nil;
}

+ (NSSortDescriptor *)sortDescriptorFromDictionary:(NSDictionary *)dict
{
    BOOL isAscending = ![[dict.allValues.first uppercaseString] isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:dict.allKeys.first ascending:isAscending];
}

+ (NSSortDescriptor *)sortDescriptorFromString:(NSString *)order
{
    NSArray *components = [order split];

    NSString *key = [components firstObject];
    NSString *value = [components count] > 1 ? components[1] : @"ASC";

    return [self sortDescriptorFromDictionary:@{key: value}];
}

+ (NSSortDescriptor *)sortDescriptorFromObject:(id)order
{
    if ([order isKindOfClass:[NSSortDescriptor class]])
        return order;

    if ([order isKindOfClass:[NSString class]])
        return [self sortDescriptorFromString:order];

    if ([order isKindOfClass:[NSDictionary class]])
        return [self sortDescriptorFromDictionary:order];

    return nil;
}

+ (NSArray *)sortDescriptorsFromObject:(id)order
{
    if ([order isKindOfClass:[NSString class]])
        order = [order componentsSeparatedByString:@","];

    if ([order isKindOfClass:[NSArray class]])
        return [order map:^id (id object) {
            return [self sortDescriptorFromObject:object];
        }];

    return @[[self sortDescriptorFromObject:order]];
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithCondition:(id)condition inContext:(NSManagedObjectContext *)context withOrder:(id)order fetchLimit:(NSNumber *)fetchLimit
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];

    if (condition)
        [request setPredicate:[self predicateFromObject:condition]];

    if (order)
        [request setSortDescriptors:[self sortDescriptorsFromObject:order]];

    if (fetchLimit)
        [request setFetchLimit:[fetchLimit integerValue]];

    return [context executeFetchRequest:request error:nil];
}

+ (NSUInteger)countForFetchWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];

    return [context countForFetchRequest:request error:nil];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key
{
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

- (BOOL)isIntegerAttributeType:(NSAttributeType)attributeType
{
    return (attributeType == NSInteger16AttributeType) ||
           (attributeType == NSInteger32AttributeType) ||
           (attributeType == NSInteger64AttributeType);
}


#pragma mark - Date Formatting

- (NSDateFormatter *)defaultFormatter
{
    static NSDateFormatter *sharedFormatter;
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        [sharedFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    });

    return sharedFormatter;
}

@end
