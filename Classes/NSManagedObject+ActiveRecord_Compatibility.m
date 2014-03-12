#import "NSManagedObject+ActiveRecord_Compatibility.h"
#import "NSManagedObject+ActiveRecord.h"
#import "ObjectiveRelation.h"

@implementation NSManagedObject (ActiveRecord_Compatibility)

#pragma mark - Default context

+ (NSArray *)allWithOrder:(id)order {
    return [[self order:order] fetchedObjects];
}

+ (NSArray *)where:(id)condition order:(id)order {
    return [[[self where:condition] order:order] fetchedObjects];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit {
    return [[[self where:condition] limit:[limit integerValue]] fetchedObjects];
}

+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit {
    return [[[[self where:condition] order:order] limit:[limit integerValue]] fetchedObjects];
}

+ (NSUInteger)countWhere:(id)condition, ... {
    va_list va_arguments;
    va_start(va_arguments, condition);
    id relation = [[self all] where:condition arguments:va_arguments];
    va_end(va_arguments);

    return [relation count];
}

+ (instancetype)first {
    return [[self all] firstObject];
}

+ (instancetype)last {
    return [[self all] lastObject];
}

#pragma mark - Custom context

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] fetchedObjects];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order {
    return [[[self inContext:context] order:order] fetchedObjects];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context {
    return [[[self inContext:context] where:condition] fetchedObjects];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order {
    return [[[[self inContext:context] where:condition] order:order] fetchedObjects];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit {
    return [[[[self inContext:context] where:condition] limit:[limit integerValue]] fetchedObjects];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit {
    return [[[[[self inContext:context] where:condition] order:order] limit:[limit integerValue]] fetchedObjects];
}

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] count];
}

+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context {
    return [[[self inContext:context] where:condition] count];
}

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] findOrCreate:properties];
}

+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] find:condition];
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] create];
}

+ (instancetype)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    return [[self inContext:context] create:attributes];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context {
    [[self inContext:context] deleteAll];
}

@end
