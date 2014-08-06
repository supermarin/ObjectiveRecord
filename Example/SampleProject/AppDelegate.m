//
//  AppDelegate.m
//  SampleProject
//
//  Created by Marin Usalj on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "JSONUtility.h"
#import "Person+Mappings.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [CoreDataManager sharedManager];
    
    __block Person *person;
    
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    newContext.persistentStoreCoordinator = [[CoreDataManager sharedManager] persistentStoreCoordinator];
    
    //NSDictionary *payload = JSON(@"people");
    
    // TODO: A 3-level-deep relationship will cause a crash, due to an invalid predicate
    // Known issue: https://github.com/supermarin/ObjectiveRecord/issues/60
    NSDictionary *payload = JSON(@"people_fail");
    
    person = [Person create:payload inContext:newContext];

    NSLog(@"%@", [person description]);
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CoreDataManager sharedManager] saveContext];
}


@end
