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

- (BOOL)save;
- (void)delete;
+ (void)deleteAll;

+ (id)create;
+ (id)create:(NSDictionary *)attributes;
- (void)update:(NSDictionary *)attributes;
+ (void)updateAll:(NSDictionary *)attributes;

+ (instancetype)findOrCreate:(NSDictionary *)attributes;
+ (instancetype)find:(id)condition, ...;

+ (id)all;
+ (id)where:(id)condition, ...;
+ (id)order:(id)condition;
+ (id)reverseOrder;
+ (id)limit:(NSUInteger)limit;
+ (id)offset:(NSUInteger)offset;
+ (id)inContext:(NSManagedObjectContext *)context;

+ (instancetype)first;
+ (instancetype)last;
+ (NSUInteger)count;

#pragma mark - Naming

+ (NSString *)entityName;

@end
