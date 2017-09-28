//
//  ViewImageViewController.h
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface ViewImageViewController : BaseViewController

@property (nonatomic, assign) BOOL isFromUpload;
@property (nonatomic, strong) PFObject *imageObject;

@end
