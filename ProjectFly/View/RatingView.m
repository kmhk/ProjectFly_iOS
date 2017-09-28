//
//  RatingView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "RatingView.h"

@interface RatingView()

@end

@implementation RatingView

- (void) awakeFromNib
{

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWith:(UIImage *) selectedImage image:(UIImage *)unselectedImage size:(CGSize) starSize interval:(float)interval
{
    self = [super init];
    if (self) {
        
        self.rate = 0;

        self.selectedStarImage = selectedImage;
        self.unselectedStarImage = unselectedImage;
        
        self.szStar = starSize;
        
        self.intervalOfStars = interval;
        
        [self rebuildSelf];
    }
    return self;
}

- (void) rebuildSelf
{
    CGPoint center = self.center;
    
    self.frame = CGRectMake(0, 0, self.szStar.width + self.intervalOfStars * 4, self.szStar.height);
    self.center = center;
    
    for (int n = 1 ; n < 6 ; n ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = self.unselectedStarImage;
        imageView.tag = n;
        imageView.frame = CGRectMake(0, 0, self.szStar.width, self.szStar.height);
        imageView.center = CGPointMake(self.szStar.width / 2 + self.intervalOfStars * (n - 1), self.frame.size.height / 2);
        
        [self addSubview:imageView];
    }
    
    [self updateUI];
}

- (void) setRate:(int)rate
{
    _rate = rate;
    
    [self updateUI];
}

- (void) updateUI
{
    for (int n = 1 ; n < 6 ; n ++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:n];
        
        if(n <= self.rate)
        {
            imageView.image = self.selectedStarImage;
        }
        else
        {
            imageView.image = self.unselectedStarImage;
        }
    }
}

- (void) setTouchPoint:(float)position
{
    float floatRate = (position - self.szStar.width / 2) / self.intervalOfStars;
    
    self.rate = MIN((int) (floatRate + 0.5f) + 1, 5);
    
    [self updateUI];
    
    [self.delegate updatedRate:self.rate];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [self setTouchPoint:touchLocation.x];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [self setTouchPoint:touchLocation.x];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
