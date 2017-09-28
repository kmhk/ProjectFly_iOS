//
//  ImageView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <Parse/Parse.h>

#define EDIT_PROFILE_HEIGHT  190

@protocol ImageViewDelegate <NSObject>

- (void) profileWithUploader:(PFUser *)uploader;
- (void) flagWithImage:(NSDictionary *)image;
- (void) likeWithImage:(NSDictionary *)image;
- (void) openImageWithImage:(UIImage *)image;

@end

@interface ImageView : UIView

@property (nonatomic, assign) id<ImageViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *ivImage;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIView *viewImage;

@property (weak, nonatomic) IBOutlet UIImageView *ivUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;

@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIImageView *ivOccasionIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivGenderIcon;

@property (weak, nonatomic) IBOutlet UILabel *lblCaption;

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;
@property (nonatomic, strong) NSString *locationOfImage;
@property (nonatomic, strong) PFUser *pfoUploader;

- (void)_update;

@end
