#import <Foundation/Foundation.h>

@interface ObjectiveRelation : NSObject <NSFastEnumeration>

@property (readonly) NSArray *fetchedObjects;

+ (instancetype)relationWithEntity:(Class)entity;

- (void)deleteAll;
- (void)updateAll:(NSDictionary *)attributes;

- (id)create;
- (id)create:(NSDictionary *)attributes;

- (id)all;
- (id)where:(id)condition, ...;
- (id)where:(id)condition arguments:(va_list)arguments;
- (id)order:(id)condition;
- (id)reverseOrder;
- (id)limit:(NSUInteger)limit;
- (id)offset:(NSUInteger)offset;
- (id)inContext:(NSManagedObjectContext *)context;

- (id)findOrCreate:(NSDictionary *)properties;
- (id)find:(id)condition, ...;

- (id)first;
- (id)last;
- (NSUInteger)count;

@end
