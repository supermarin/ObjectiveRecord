//
//  NSManagedObject+Mappings.h
//  CORE
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright (c) 2013 Clinically Relevant. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Mappings)

/// Needs to be overriden in your entity. Not required if you don't have mappings
- (NSDictionary *)mappings;

/// If your web service returns `first_name`, and locally you have `firstName` this method handles mapped keys
- (id)keyForRemoteKey:(NSString *)key;

@end
