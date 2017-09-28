//
//  ProfileViewController.h
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController : BaseViewController

@property (nonatomic, assign) BOOL isOwner;
@property (strong, nonatomic) PFUser *pfoUser;

@end
