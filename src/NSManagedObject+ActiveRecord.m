//
//  NSManagedObject+ActiveRecord.m
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

#import "NSManagedObject+ActiveRecord.h"

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

+ (NSArray *)where:(id)request, ...
{
    va_list va_arguments;
    va_start(va_arguments, request);
    NSArray *arguments = [self arrayFromVaList:va_arguments];
    va_end(va_arguments);
    return [self whereFromContext:[NSManagedObjectContext defaultContext] condition:request arguments:arguments];
}

+ (NSArray *)whereFromContext:(NSManagedObjectContext *)context condition:(id)request, ...
{
    va_list va_arguments;
    va_start(va_arguments, request);
    NSArray *arguments = [self arrayFromVaList:va_arguments];
    va_end(va_arguments);
    return [self whereFromContext:context condition:request arguments:arguments];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context {
    
    return [self whereFromContext:context condition:condition arguments:nil];
}

+ (NSArray *)whereFromContext:(NSManagedObjectContext *)context condition:(id)request arguments:(NSArray *)arguments
{
    if ([request isKindOfClass:[NSString class]]) {
        return [self fetchWithPredicate:[self predicateFromString:request withArray:arguments] inContext:context];
    } else if ([request isKindOfClass:[NSDictionary class]]) {
        return [self fetchWithPredicate:[self predicateFromDictionary:request] inContext:context];
    } else {
        return nil;
    }
}


#pragma mark - Creation / Deletion

+ (id)create {
    return [self createInContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes {
    return [self create:attributes
              inContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    NSManagedObject *newEntity = [self createInContext:context];
    
    [newEntity setValuesForKeysWithDictionary:attributes];
    return newEntity;
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                         inManagedObjectContext:context];
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

#pragma mark - Private

+ (NSString *)queryStringFromDictionary:(NSDictionary *)conditions {
    NSMutableString *queryString = [NSMutableString new];
    
    [conditions.allKeys each:^(id attribute) {
        [queryString appendFormat:@"%@ == '%@'",
         attribute, [conditions valueForKey:attribute]];
        if (attribute == conditions.allKeys.last) return;
        [queryString appendString:@" AND "];
    }];
    
    return queryString;
}

+ (NSArray *)arrayFromVaList:(va_list)va_arguments
{
    NSMutableArray *arguments = [NSMutableArray array];
    id object;
    while ((object = va_arg( va_arguments, id))) {
        [arguments addObject:object];
    }
    return arguments;
}

+ (NSPredicate *)predicateFromString:(NSString*)format withArray:(NSArray *)arguments
{
    if (arguments != nil && [arguments count] > 0) {
        return [NSPredicate predicateWithFormat:format argumentArray:arguments];
    } else {
        return [NSPredicate predicateWithFormat:format];
    }
}

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dictionary
{
    return [NSPredicate predicateWithFormat:[self queryStringFromDictionary:dictionary]];
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self)
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    if (fetchedObjects.count > 0) return fetchedObjects;
    return nil;
}

- (BOOL)saveTheContext {

    if (self.managedObjectContext == nil ||
        ![self.managedObjectContext hasChanges]) return YES;
    
    NSError *error = nil;
    BOOL save = [self.managedObjectContext save:&error];

    if (!save || error) {
        NSLog(@"Unresolved error in saving context for entity: %@!\n Error:%@", self, error);
        return NO;
    }
    
    return YES;
}

@end