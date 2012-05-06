//
//  NSManagedObject+ActiveRecord.m
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

#import "NSManagedObject+ActiveRecord.h"
#import "CoreDataManager.h"

@implementation NSManagedObject (ActiveRecord)

- (BOOL)save {
    if (self.managedObjectContext == nil) return NO;
    if (![self.managedObjectContext hasChanges])return NO;
    
    NSError *error = nil;    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error in saving entity: %@!\n Error:%@, %@",NSStringFromClass([self class]), error, [error userInfo]);
        return NO;
    }
    
    return YES;
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}


#pragma mark - Finders

+ (NSArray *)all {
    return [self allInContext:[[CoreDataManager instance] managedObjectContext]];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self) 
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *allEntities = [context executeFetchRequest:request error:&error];
    return allEntities;
}

+ (NSArray *)where:(NSString *)condition inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest new];
    
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self) 
                                 inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:condition];    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];

    if (fetchedObjects.count > 0) return fetchedObjects;
    return nil;
}

+ (NSArray *)where:(NSString *)condition {
    return [self where:condition inContext:[[CoreDataManager instance] managedObjectContext]];
}


#pragma mark - Creation

+ (id)create {
    return [self createInContext:[[CoreDataManager instance] managedObjectContext]];
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) 
                                                            inManagedObjectContext:context];
    
    return entity;
}

@end