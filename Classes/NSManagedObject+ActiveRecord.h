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

@class ObjectiveRelation;

@interface NSManagedObjectContext (ActiveRecord)

/**
 The default context (as defined on the @c CoreDataManager singleton).

 @see -[CoreDataManager managedObjectContext]

 @return A managed object context.
 */
+ (NSManagedObjectContext *)defaultContext;

@end

@interface NSManagedObject (ActiveRecord)

#pragma mark - Fetch request building

+ (ObjectiveRelation *)all;
+ (ObjectiveRelation *)where:(id)condition, ...;
+ (ObjectiveRelation *)order:(id)order;
+ (ObjectiveRelation *)reverseOrder;
+ (ObjectiveRelation *)limit:(NSUInteger)limit;
+ (ObjectiveRelation *)offset:(NSUInteger)offset;
+ (ObjectiveRelation *)inContext:(NSManagedObjectContext *)context;

#pragma mark Counting

+ (NSUInteger)count;
+ (BOOL)any;

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

#pragma mark - Relations

- (id)relationWithName:(NSString *)name;

#pragma mark - Naming

+ (NSString *)entityName;

@end
