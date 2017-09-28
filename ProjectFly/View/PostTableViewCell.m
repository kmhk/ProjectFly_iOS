//
//  PostTableViewCell.m
//  Fly
//
//  Created by han on 3/8/15.
//
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImage)];
    likeTap.numberOfTapsRequired = 2;
    
    [self.viewImage addGestureRecognizer:likeTap];
    
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage)];
    openTap.numberOfTapsRequired = 1;
    
    [self.viewImage addGestureRecognizer:openTap];
    
    [openTap requireGestureRecognizerToFail:likeTap];
}

- (void) likeImage
{
    if (self.imageObject && [[self.imageObject[@"uploader"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
    } else {
        if (!self.isFromFavoriteViewController) {
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
            imageView.center = self.ivImage.center;
            
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
        }
        
        [self.delegate likeWithImage:nil];
    }
}

- (void) openImage
{
    [self.delegate openImageWithPostTableViewCell:self.ivImage.image];
}

- (void) showTags
{
    self.viewTags.hidden = NO;
}

- (void) hideTags
{
    self.viewTags.hidden = YES;
}

- (IBAction)onTag:(id)sender
{
    [self.delegate showTagWithPostTableViewCell];
}

- (IBAction)onSubmenu:(id)sender
{
    [self.delegate submenuWithPostTableViewCell:200];
}

@end

