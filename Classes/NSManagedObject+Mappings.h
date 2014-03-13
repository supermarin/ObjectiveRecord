//
//  NSManagedObject+Mappings.h
//  CORE
//
//  Created by Marin Usalj on 5/28/13.
//  Copyright (c) 2013 Clinically Relevant. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Mappings)

/**
 A dictionary mapping remote (server) attribute names to local (Core Data) attribute names. Optionally overridden in NSManagedObject subclasses.

 @return A dictionary.
 */
+ (NSDictionary *)mappings;

/**
 Returns a Core Data attribute name for a remote attribute name. Returns values defined in @c +mappings or, by default, converts snake case to camel case (e.g., @c @@"first_name" becomes @c @@"firstName").

 @see +[NSManagedObject mappings]

 @param key A remote (server) attribute name.

 @return A local (Core Data) attribute name.
 */
+ (id)keyForRemoteKey:(NSString *)key;

/**
 The keypath uniquely identifying your entity. Usually an ID, e.g., @c @@"remoteID".

 @return An attribute name.
 */
+ (id)primaryKey;

@end
