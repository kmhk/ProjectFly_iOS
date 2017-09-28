//
//  PostHeaderView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#define POST_HEADER_HEIGHT  82

@protocol PostHeaderViewDelegate <NSObject>

- (void) openUserProfileWithPostHeaderView:(PFUser *)uploader;

@end

@interface PostHeaderView : UIView

@property (nonatomic, assign) id <PostHeaderViewDelegate> delegate;

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, strong) NSString *locationText;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;

@property (weak, nonatomic) IBOutlet UILabel *lblUsername;

@property (weak, nonatomic) IBOutlet UILabel *lblMarks;

@property (weak, nonatomic) IBOutlet UIImageView *ivOccasionIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIImageView *ivGenderIcon;

@property (weak, nonatomic) IBOutlet UIImageView *ivUserAvatar;
@property (nonatomic, strong) PFUser *pfoUploader;

- (void) updateFilterIcons;

@end
