// NSManagedObject+ActiveRecord.h
//
// Copyright (c) 2014 Marin Usalj <http://supermar.in>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <CoreData/CoreData.h>
#import "NSManagedObject+Mappings.h"
#import "CoreDataManager.h"

@interface NSManagedObjectContext (ActiveRecord)

/**
 The default context (as defined on the @c CoreDataManager singleton).

 @see -[CoreDataManager managedObjectContext]

 @return A managed object context.
 */
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
+ (NSArray *)where:(id)condition, ...;
+ (NSArray *)where:(id)condition order:(id)order;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit;
+ (instancetype)findOrCreate:(NSDictionary *)attributes;
+ (instancetype)find:(id)condition, ...;
+ (NSUInteger)count;
+ (NSUInteger)countWhere:(id)condition, ...;

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
+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context;

#pragma mark - Naming

+ (NSString *)entityName;

@end
