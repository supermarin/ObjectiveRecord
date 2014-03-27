// NSManagedObject+Mappings.h
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

@interface NSManagedObject (Mappings)

/**
 A dictionary mapping remote (server) attribute names to local (Core Data) attribute names. Optionally overridden in NSManagedObject subclasses.

 @return A dictionary.
 */
+ (NSDictionary *)mappings;

/**
 Returns a Core Data attribute name for a remote attribute name. Returns values defined in @c +mappings or, by default, converts snake case to camel case (e.g., @c @@"first_name" becomes @c @@"firstName").

 @see +[NSManagedObject mappings]

 @param key     A remote (server) attribute name.
 @param context A local managed object context.

 @return A local (Core Data) attribute name.
 */
+ (NSString *)keyForRemoteKey:(NSString *)remoteKey inContext:(NSManagedObjectContext *)context;

/**
 Transforms a given object for a remote attribute name.

 @param value     Object to be transformed (e.g., a dictionary may become a managed object)
 @param remoteKey A remote (server) attribute name.
 @param context   A local managed object context.

 @return A tranformed object.
 */
+ (id)transformValue:(id)value forRemoteKey:(NSString *)remoteKey inContext:(NSManagedObjectContext *)context;

/**
 The keypath uniquely identifying your entity. Usually an ID, e.g., @c @@"remoteID".

 @return An attribute name.
 */
+ (NSString *)primaryKey;

@end
