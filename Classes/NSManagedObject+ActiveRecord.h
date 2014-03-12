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

#pragma mark - Fetch request building

+ (id)all;
+ (id)where:(id)condition, ...;
+ (id)order:(id)condition;
+ (id)reverseOrder;
+ (id)limit:(NSUInteger)limit;
+ (id)offset:(NSUInteger)offset;
+ (id)inContext:(NSManagedObjectContext *)context;

#pragma mark Counting

+ (NSUInteger)count;

#pragma mark Plucking

+ (instancetype)firstObject;
+ (instancetype)lastObject;

+ (instancetype)find:(id)condition, ...;

#pragma mark - Manipulating entities

+ (instancetype)findOrCreate:(NSDictionary *)properties;

+ (instancetype)create;
+ (instancetype)create:(NSDictionary *)attributes;

+ (void)updateAll:(NSDictionary *)attributes;
- (void)update:(NSDictionary *)attributes;

- (BOOL)save;
+ (void)deleteAll;
- (void)delete;

#pragma mark - Naming

+ (NSString *)entityName;

@end
