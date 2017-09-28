//
//  ProfileExpandedViewController.h
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileExpandedViewController : UIViewController

@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) BOOL isOwner;
@property (strong, nonatomic) PFUser *pfoUser;

@end
