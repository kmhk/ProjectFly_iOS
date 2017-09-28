//
//  ImageView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "ImageView.h"

#import "DataManager.h"

@interface ImageView()

@end

@implementation ImageView

- (void) awakeFromNib
{
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImage)];
    likeTap.numberOfTapsRequired = 2;
    
    [self.viewImage addGestureRecognizer:likeTap];
    
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage)];
    openTap.numberOfTapsRequired = 1;
    
    [self.viewImage addGestureRecognizer:openTap];
    
    [openTap requireGestureRecognizerToFail:likeTap];
    
    self.occasionIndex = 1;
    self.locationIndex = 1;
    self.genderIndex = 1;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)_update
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
        self.lblLocation.text = self.locationOfImage;
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

- (IBAction)onProfile:(id)sender
{
    [self.delegate profileWithUploader:self.pfoUploader];
}

- (IBAction)onFlag:(id)sender
{
    [self.delegate flagWithImage:nil];
}

- (void) likeImage
{
    UIImage *image = [UIImage imageNamed:@"rate_icon_heart"];
    NSInteger imageWidth = CGImageGetWidth([image CGImage]);
    __block float aspectRatio = (float)self.viewImage.frame.size.width / (float)imageWidth;
    __block UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    BOOL hasMarked = YES;
    if (hasMarked)
        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    else
        imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
    
    [self.viewImage addSubview:imageView];
    [self.viewImage bringSubviewToFront:imageView];
    imageView.center = CGPointMake(self.viewImage.frame.size.width / 2, self.viewImage.frame.size.height / 2);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (hasMarked)
            imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
        else
            imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageView.alpha = 0.0f;
        } completion:^(BOOL finished){
            [imageView removeFromSuperview];
            imageView = nil;
        }];
        
    }];
    
    [self.delegate likeWithImage:nil];
}

- (void) openImage
{
    [self.delegate openImageWithImage:self.ivImage.image];
}


@end
