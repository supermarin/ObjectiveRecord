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
+ (NSDictionary *)allContexts;
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

+ (id)createInContext:(id)context;
+ (id)create:(NSDictionary *)attributes inContext:(id)context;

+ (void)deleteAllInContext:(id)context;

+ (NSArray *)allInContext:(id)context;
+ (NSArray *)allInContext:(id)context order:(id)order;
+ (NSArray *)where:(id)condition inContext:(id)context;
+ (NSArray *)where:(id)condition inContext:(id)context order:(id)order;
+ (NSArray *)where:(id)condition inContext:(id)context limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition inContext:(id)context order:(id)order limit:(NSNumber *)limit;
+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(id)context;
+ (instancetype)find:(NSDictionary *)attributes inContext:(id)context;
+ (NSUInteger)countInContext:(id)context;
+ (NSUInteger)countWhere:(id)condition inContext:(id)context;

- (void)moveToContext:(id)context;
- (void)copyToContext:(id)context;

#pragma mark - Naming

+ (NSString *)entityName;

@end
