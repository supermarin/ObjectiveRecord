//
//  NSManagedObject+ActiveRecord.h
//  WidgetPush
//
//  Created by Marin Usalj on 4/15/12.
//  Copyright (c) 2012 http://mneorr.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataManager.h"
#import "NSArray+Accessors.h"

@interface NSManagedObjectContext (ActiveRecord)
+ (NSManagedObjectContext *)defaultContext;
@end

@interface NSManagedObject (ActiveRecord)

#pragma mark - Default Context

- (BOOL)save;
- (void)delete;

+ (id)create;
+ (NSArray *)all;
+ (NSArray *)where:(NSString *)condition;



#pragma mark - Custom Context
+ (id)createInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)where:(NSString *)condition inContext:(NSManagedObjectContext *)context;    

@end