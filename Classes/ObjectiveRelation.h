// ObjectiveRelation.h
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

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@protocol ObjectiveRelation <NSObject, NSCopying, NSFastEnumeration>

#pragma mark - Fetch request building

- (instancetype)all;
- (instancetype)select:(NSArray *)keyPaths;
- (instancetype)where:(id)condition, ...;
- (instancetype)where:(id)condition arguments:(va_list)arguments;
- (instancetype)order:(id)order;
- (instancetype)reorder:(id)order;
- (instancetype)reverseOrder;
- (instancetype)limit:(NSUInteger)limit;
- (instancetype)offset:(NSUInteger)offset;
- (instancetype)section:(NSString *)keyPath;

- (NSPredicate *)predicate;
- (NSArray *)sortDescriptors;
@property (readonly, nonatomic) NSUInteger limit;
@property (readonly, nonatomic) NSUInteger offset;
@property (readonly, nonatomic) NSString *sectionNameKeyPath;

@property (readonly, nonatomic) NSArray *fetchedObjects;

#pragma mark Counting

- (NSUInteger)count;
- (BOOL)any;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section;

#pragma mark Plucking

- (id)firstObject;
- (id)lastObject;
- (id)find:(id)condition, ...;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ObjectiveRelation : NSObject <ObjectiveRelation>

+ (NSArray *)sectionObjects:(NSArray *)objects byKeyPath:(NSString *)keyPath;

- (id)initWithObjects:(NSArray *)objects;

@end
