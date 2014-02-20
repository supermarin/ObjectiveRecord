//
//  NSManagedObject+ActiveRecord.m
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

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

+ (NSArray *)whereFormat:(NSString *)format, ... {
    va_list va_arguments;
    va_start(va_arguments, format);
    NSString *condition = [[NSString alloc] initWithFormat:format arguments:va_arguments];
    va_end(va_arguments);

    return [self where:condition];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties {
    return [self findOrCreate:properties inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context {
    NSManagedObject *existing = [self where:properties inContext:context].first;
    return existing ?: [self create:properties inContext:context];
}

+ (instancetype)find:(NSDictionary *)attributes {
    return [self find:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)find:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    return [self where:attributes inContext:context limit:@1].first;
}

+ (NSArray *)where:(id)condition {
    return [self where:condition inContext:[NSManagedObjectContext defaultContext]];
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

+ (NSUInteger)countWhere:(id)condition {
    return [self countWhere:condition inContext:[NSManagedObjectContext defaultContext]];
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

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict {
    NSArray *subpredicates = [dict map:^(id key, id value) {
        return [NSPredicate predicateWithFormat:@"%K == %@", [self keyForRemoteKey:key], value];
    }];

    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition {

    if ([condition isKindOfClass:[NSPredicate class]])
        return condition;

    else if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition];

    else if ([condition isKindOfClass:[NSDictionary class]])
        return [self predicateFromDictionary:condition];

    return nil;
}

+ (NSSortDescriptor *)sortDescriptorFromDictionary:(NSDictionary *)dict {
    BOOL isAscending = ![[dict.allValues.first uppercaseString] isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:dict.allKeys.first
                                         ascending:isAscending];
}

+ (NSSortDescriptor *)sortDescriptorFromObject:(id)order {
    if ([order isKindOfClass:[NSSortDescriptor class]])
        return order;

    else if ([order isKindOfClass:[NSString class]])
        return [NSSortDescriptor sortDescriptorWithKey:order ascending:YES];

    else if ([order isKindOfClass:[NSDictionary class]])
        return [self sortDescriptorFromDictionary:order];

    return nil;
}

+ (NSArray *)sortDescriptorsFromObject:(id)order {
    if ([order isKindOfClass:[NSArray class]])
        return [order map:^id (id object) {
            return [self sortDescriptorFromObject:object];
        }];

    else
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

- (void)hydrateObject:(id)properties ofClass:(Class)class forKey:(NSString *)key {
    [self setSafeValue:[self objectOrSetOfObjectsFromValue:properties ofClass:class]
                forKey:key];
}

- (id)objectOrSetOfObjectsFromValue:(id)value ofClass:(Class)class {
    if ([value isKindOfClass:[NSDictionary class]])
        return [class findOrCreate:value inContext:self.managedObjectContext];
    
    else if ([value isKindOfClass:[NSArray class]])
        return [NSSet setWithArray:[value map:^id(NSDictionary *dict) {
            return [class findOrCreate:dict inContext:self.managedObjectContext];
        }]];
    else
        return [class findOrCreate:@{ [class primaryKey]: value } inContext:self.managedObjectContext];
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
