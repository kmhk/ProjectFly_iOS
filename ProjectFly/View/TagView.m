//
//  TagView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "TagView.h"

@interface TagView()

@end

@implementation TagView

- (void) awakeFromNib
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSelf:)];
    
    [self addGestureRecognizer:panGesture];
    panGesture = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onClose:(id)sender
{
    [self.delegate closeTag:self];
    
    [self removeFromSuperview];
}

- (void) initState
{
    self.lblTagName.text = @"What is this?";
    self.lblTagName.textColor = [UIColor colorWithRed:151.0f / 255.0f green:151.0f / 255.0f blue:151.0f / 255.0f alpha:1.0f];
    self.item = self.lblTagName.text;
    [self moveSelf:[[UIPanGestureRecognizer alloc] init]];
}

- (void) startEdit
{
    self.btnClose.alpha = 0.0;
    self.btnClose.userInteractionEnabled = NO;
}

- (void) done:(NSString *)tagName
{
    self.btnClose.alpha = 1.0f;
    self.btnClose.userInteractionEnabled = YES;
    
    CGRect rect = [tagName boundingRectWithSize:CGSizeMake(400, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblTagName.font} context:nil];
    
    self.lblTagName.text = tagName;
    self.lblTagName.textColor = [UIColor whiteColor];
    
    float centerX = self.center.x;
    float width = rect.size.width + 30;
    
    self.frame = CGRectMake(centerX - width / 2, self.frame.origin.y, width, self.frame.size.height);
}

- (void) moveSelf:(UIPanGestureRecognizer *)gesture
{
    if (self.isMove) {
        CGPoint translation = [gesture translationInView:self];
        
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        if (self.frame.origin.x < 0) {
            [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        }
        if (self.frame.origin.y < 0) {
            [self setFrame:CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height)];
        }
        //NSLog(@"%f, %f", self.superview.frame.size.width, self.superview.frame.size.height);
        if (self.frame.origin.x + self.frame.size.width > self.superview.frame.size.width) {
            [self setFrame:CGRectMake(self.superview.frame.size.width - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        }
        if (self.frame.origin.y + self.frame.size.height > self.superview.frame.size.height) {
            [self setFrame:CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        }
        //NSLog(@"%f, %f", self.frame.origin.x, self.frame.origin.y);
        
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
    }
}

@end
