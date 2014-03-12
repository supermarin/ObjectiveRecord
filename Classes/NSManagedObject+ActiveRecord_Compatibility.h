#import <CoreData/CoreData.h>

@interface NSManagedObject (ActiveRecord_Compatibility)

#pragma mark - Default context

+ (NSArray *)allWithOrder:(id)order __deprecated;
+ (NSArray *)where:(id)condition order:(id)order __deprecated;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit __deprecated;
+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit __deprecated;

+ (NSUInteger)countWhere:(id)condition, ... __deprecated;

+ (instancetype)first __deprecated;
+ (instancetype)last __deprecated;

#pragma mark - Custom context

+ (NSArray *)allInContext:(NSManagedObjectContext *)context __deprecated;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order __deprecated ;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context __deprecated;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order __deprecated;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit __deprecated;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit __deprecated;

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context __deprecated;
+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context __deprecated;

+ (instancetype)findOrCreate:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context __deprecated;
+ (instancetype)find:(id)condition inContext:(NSManagedObjectContext *)context __deprecated;
+ (instancetype)createInContext:(NSManagedObjectContext *)context __deprecated;
+ (instancetype)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context __deprecated;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context __deprecated;

@end
