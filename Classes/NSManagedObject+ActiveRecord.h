//
//  NSManagedObject+ActiveRecord.h
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+Mappings.h"
#import "CoreDataManager.h"

@interface NSManagedObjectContext (ActiveRecord)
+ (NSManagedObjectContext *)defaultContext;
@end

@interface NSManagedObject (ActiveRecord)


#pragma mark - Default Context

- (BOOL)save;
- (void)delete;
+ (void)deleteAll;

+ (id)create;
+ (id)create:(NSDictionary *)attributes;
- (void)update:(NSDictionary *)attributes;

+ (NSArray *)all;
+ (NSArray *)allWithOrder:(id)order;
+ (NSArray *)where:(id)condition;
+ (NSArray *)where:(id)condition order:(id)order;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit;
+ (NSArray *)whereFormat:(NSString *)format, ...;
+ (instancetype)findOrCreate:(NSDictionary *)attributes;
+ (instancetype)find:(NSDictionary *)attributes;
+ (NSUInteger)count;
+ (NSUInteger)countWhere:(id)condition;

#pragma mark - Custom Context

+ (id)createInContext:(NSManagedObjectContext *)context;
+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;

+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit;
+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context;
+ (instancetype)find:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context;

#pragma mark - Naming

+ (NSString *)entityName;

@end
