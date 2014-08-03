//
//  AppDelegate.m
//  Homepwner
//
//  Created by Lumi on 14-7-4.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "AppDelegate.h"
#import "LNGItemsViewController.h"
#import "LNGItemStore.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // If state restoration did not occur, set up the view controller hierarchy
    if (!self.window.rootViewController) {
        LNGItemsViewController *itemsViewController = [[LNGItemsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
        
        // Give the navigation controller a restoration identifier
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        
        self.window.rootViewController = navController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[LNGItemStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the LNGItems");
    } else {
        NSLog(@"Could not save any of the LNGItems");
    }
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    // Create a new navigation controller
    UIViewController *vc = [[UINavigationController alloc] init];
    
    // The last object in the path is the restoration identifier for this view controller
    vc.restorationIdentifier = [identifierComponents lastObject];
    
    if ([identifierComponents count] == 1) {
        self.window.rootViewController = vc;
    } else {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return vc;
}

@end
