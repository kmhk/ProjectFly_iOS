//
//  PostHeaderView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "PostHeaderView.h"

#import "DataManager.h"

@interface PostHeaderView()

@end

@implementation PostHeaderView

- (void) awakeFromNib
{
    self.locationIndex = 1;
    self.occasionIndex = 1;
    self.genderIndex = 1;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) updateFilterIcons
{
    float pos = self.frame.size.width - 10;
    
    self.ivGenderIcon.hidden = NO;
    if(self.genderIndex == 0)
    {
        self.ivGenderIcon.hidden = YES;
    }
    else if(self.genderIndex == 1)
    {
        self.ivGenderIcon.image = [UIImage imageNamed:@"common_icon_female"];
    }
    else if(self.genderIndex == 2)
    {
        self.ivGenderIcon.image = [UIImage imageNamed:@"common_icon_male"];
    }
    
    if(!self.ivGenderIcon.isHidden)
    {
        self.ivGenderIcon.center = CGPointMake(pos - self.ivGenderIcon.frame.size.width / 2, self.lblUsername.center.y);
        pos -= self.ivGenderIcon.frame.size.width;
    }
    
    self.ivOccasionIcon.hidden = NO;
    if(self.occasionIndex == 0)
    {
        self.ivOccasionIcon.hidden = YES;
    }
    else if(self.occasionIndex == 1)
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_nightlife"];
    }
    else if(self.occasionIndex == 2)
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_professional"];
    }
    else
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_streetwear"];
    }
    
    if(!self.ivOccasionIcon.isHidden)
    {
        self.ivOccasionIcon.center = CGPointMake(pos - self.ivOccasionIcon.frame.size.width / 2, self.lblUsername.center.y);
        pos -= self.ivOccasionIcon.frame.size.width;
    }
    
    self.lblLocation.hidden = NO;
    if(self.locationIndex == 0)
    {
        self.lblLocation.hidden = YES;
    }
    else
    {
        //self.lblLocation.text = locations[self.locationIndex];
        self.lblLocation.text = self.locationText;
        [self.lblLocation sizeToFit];
        
        if(self.locationIndex == 1)
            self.lblLocation.backgroundColor = [UIColor colorWithRed:153.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f];
        else if(self.locationIndex == 2)
            self.lblLocation.backgroundColor = [UIColor colorWithRed:51.0f / 255.0f green:102.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        else
            self.lblLocation.backgroundColor = [UIColor colorWithRed:51.0f / 255.0f green:102.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
        
        self.lblLocation.frame = CGRectMake(0, 0, self.lblLocation.frame.size.width + 10, [DataManager is6PlusScreen] ? 20 : 16);
    }
    
    self.lblLocation.center = CGPointMake (pos - self.lblLocation.frame.size.width / 2 - 5, self.lblUsername.center.y);
}

- (IBAction)onUserProfile:(id)sender
{
    [self.delegate openUserProfileWithPostHeaderView:self.pfoUploader];
}


@end
