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


+ (NSArray *)where:(id)condition {
    
    return [self where:condition 
             inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context {

    return [self fetchWithPredicate:[self predicateFromStringOrDict:condition]
                          inContext:context];
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
    if (self.managedObjectContext == nil) return NO;
    if (![self.managedObjectContext hasChanges])return NO;
    
    NSError *error = nil;    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error in saving entity: %@!\n Error:%@", self, error);
        return NO;
    }
    
    return YES;
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

+ (NSPredicate *)predicateFromStringOrDict:(id)condition {
    
    if ([condition isKindOfClass:[NSString class]]) 
        return [NSPredicate predicateWithFormat:condition];
    
    else if ([condition isKindOfClass:[NSDictionary class]]) 
        return [NSPredicate predicateWithFormat:[self queryStringFromDictionary:condition]];

    return nil;
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

@end