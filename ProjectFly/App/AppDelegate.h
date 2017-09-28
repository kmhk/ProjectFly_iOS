//
//  AppDelegate.h
//  ProjectFly
//
//  Created by han on 2/20/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)profileUpdated:(NSNotification *) notification;

@end

