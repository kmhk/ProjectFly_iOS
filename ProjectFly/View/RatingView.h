//
//  RatingView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingViewDelegate <NSObject>

- (void) updatedRate:(float)rate;

@end

@interface RatingView : UIView

@property (nonatomic, assign) int rate;

@property (nonatomic, strong) UIImage *selectedStarImage;
@property (nonatomic, strong) UIImage *unselectedStarImage;

@property (nonatomic, assign) CGSize szStar;

@property (nonatomic, assign) float intervalOfStars;

@property (nonatomic, assign) id<RatingViewDelegate> delegate;

- (id) initWith:(UIImage *) selectedImage image:(UIImage *)unselectedImage size:(CGSize) starSize interval:(float)interval;

@end
