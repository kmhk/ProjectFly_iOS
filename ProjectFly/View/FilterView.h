//
//  MenuView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewDelegate <NSObject>

- (void) applyFilterOption;

@end

@interface FilterView : UIView

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;

@property (nonatomic, assign) id<FilterViewDelegate> delegate;

- (void) showMenu;
- (void) hideMenu;
- (BOOL) isShownMenu;

@end
