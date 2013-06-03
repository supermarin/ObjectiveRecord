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
    return [[CoreDataManager instance] managedObjectContext];
}
@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - Finders

+ (NSArray *)all {
    return [self allInContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    return [self fetchWithPredicate:nil inContext:context];
}

+ (NSArray *)whereFormat:(NSString *)format, ... {
    va_list va_arguments;
    va_start(va_arguments, format);
    NSString *condition = [[NSString alloc] initWithFormat:format arguments:va_arguments];
    va_end(va_arguments);

    return [self where:condition];
}

+ (NSArray *)where:(id)condition {
    return [self where:condition inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context {
    
    NSPredicate *predicate = ([condition isKindOfClass:[NSPredicate class]]) ? condition
                                                                             : [self predicateFromStringOrDict:condition];
    
    return [self fetchWithPredicate:predicate inContext:context];
}


#pragma mark - Creation / Deletion

+ (id)create {
    return [self createInContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes {
    return [self create:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    NSManagedObject *newEntity = [self createInContext:context];
    [newEntity update:attributes];
    
    return newEntity;
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

- (void)update:(NSDictionary *)attributes {
    
    [attributes each:^(id key, id value) {
        id remoteKey = [self keyForRemoteKey:key];
        
        if ([remoteKey isKindOfClass:[NSString class]])
            [self setValue:value forKey:remoteKey];
        else
            [self hydrateObject:value ofClass:remoteKey[@"class"] forKey:remoteKey[@"key"] ?: key];
    }];
}

- (BOOL)save {
    return [self saveTheContext];
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
    [self saveTheContext];
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

+ (NSString *)queryStringFromDictionary:(NSDictionary *)conditions {
    NSMutableString *queryString = [NSMutableString new];
    
    
    [conditions each:^(id attribute, id value) {
        [queryString appendFormat:@"%@ == '%@'", attribute, value];
        
        if (attribute == conditions.allKeys.last) return;
        [queryString appendString:@" AND "];
    }];
    
    return queryString;
}

+ (NSPredicate *)predicateFromStringOrDict:(id)condition {
    
    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition];
    
    else if ([condition isKindOfClass:[NSDictionary class]])
        return [NSPredicate predicateWithFormat:[self queryStringFromDictionary:condition]];
    
    return nil;
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    return fetchedObjects.count > 0 ? fetchedObjects : nil;
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
    [self setValue:[self objectOrSetOfObjectsFromValue:properties ofClass:class]
            forKey:key];
}

- (id)objectOrSetOfObjectsFromValue:(id)value ofClass:(Class)class {
    
    if ([value isKindOfClass:[NSArray class]])
        return [NSSet setWithArray:[value map:^id(NSDictionary *dict) {
            return [class create:dict inContext:self.managedObjectContext];
        }]];
    
    else return [class create:value inContext:self.managedObjectContext];
}

@end