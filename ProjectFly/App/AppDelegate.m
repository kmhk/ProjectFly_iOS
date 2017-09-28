//
//  AppDelegate.m
//  ProjectFly
//
//  Created by han on 2/20/15.
//
//

#import "AppDelegate.h"
#import "DataManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"osUmV3TYaXEA2uAaJ9vNBG4roLMA9YsXiwCqPsjF"
                  clientKey:@"5cBXtTQRr8xWUWw8EGMfd4WjmmQ2UvDuUMKpTfJy"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    NSString *storyboardName = [DataManager getXibName:@"Main"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:rtScreen];
    self.window.rootViewController = [mainStoryboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    //return YES;
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)profileUpdated:(NSNotification *) notification {
    PFUser *currentParseUser = [PFUser currentUser];
    FBSDKProfile *currentFBProfile = [FBSDKProfile currentProfile];
    currentParseUser[@"facebookUserObjectId"] = currentFBProfile.userID;
    currentParseUser[@"name"] = currentFBProfile.name;
    currentParseUser[@"firstName"] = currentFBProfile.firstName;
    currentParseUser[@"lastName"] = currentFBProfile.lastName;
    currentParseUser[@"facebookLink"] = currentFBProfile.linkURL;
    [currentParseUser saveInBackground];
}

@end
