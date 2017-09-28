//
//  AlertView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertViewDelegate <NSObject>

- (void) onOkWithAlertView:(UIView *)alertView;
- (void) onCancelWithAlertView:(UIView *)alertView;

@end

@interface AlertView : UIView

@property (nonatomic, assign) id<AlertViewDelegate> delegate;

+ (void) ShowAlertView:(UIView *)inView delegate:(id)delegate title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok tag:(int)tag;

@end
