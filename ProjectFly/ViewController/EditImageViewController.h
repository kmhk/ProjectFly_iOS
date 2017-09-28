//
//  EditImageViewController.h
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface EditImageViewController : BaseViewController

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *arrayOfTags;
@property (nonatomic, strong) PFObject *imageObject;

@end
