//
//  NotificationTableViewCell.m
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.viewMain.layer.borderWidth = 1.0f;
    self.viewMain.layer.borderColor = [UIColor colorWithRed:198.0f / 255.0f green:198.0f / 255.0f blue:198.0f / 255.0f alpha:1.0f].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setMoreButton:(BOOL)isMoreButton
{
    if(isMoreButton)
    {
        self.ivImage.hidden = YES;
        self.lblValue.hidden = YES;
        self.lblMessage.hidden = YES;
        self.lblTime.hidden = YES;
        
        self.lblClickToMoreView.hidden = NO;
    }
    else
    {
        self.ivImage.hidden = NO;
        self.lblValue.hidden = NO;
        self.lblMessage.hidden = NO;
        self.lblTime.hidden = NO;
        
        self.lblClickToMoreView.hidden = YES;
    }
}

@end
