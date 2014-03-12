#import <Foundation/Foundation.h>

@interface ObjectiveRelation : NSObject <NSFastEnumeration>

+ (instancetype)relationWithEntity:(Class)entity;

#pragma mark - Fetch request building

- (id)all;
- (id)where:(id)condition, ...;
- (id)where:(id)condition arguments:(va_list)arguments;
- (id)order:(id)condition;
- (id)reverseOrder;
- (id)limit:(NSUInteger)limit;
- (id)offset:(NSUInteger)offset;
- (id)inContext:(NSManagedObjectContext *)context;

#pragma mark Counting

- (NSUInteger)count;

#pragma mark Plucking

- (id)firstObject;
- (id)lastObject;
- (id)find:(id)condition, ...;

#pragma mark - Manipulating entities

- (id)findOrCreate:(NSDictionary *)properties;

- (id)create;
- (id)create:(NSDictionary *)attributes;

- (void)updateAll:(NSDictionary *)attributes;

- (void)deleteAll;

@end
