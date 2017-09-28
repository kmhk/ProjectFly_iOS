//
//  ActionSheetView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionSheetViewDelegate <NSObject>

- (void) onButtonClickWithActionsheet:(UIView *)actionSheetView index:(int)index;

@end

@interface ActionSheetView : UIView

@property (nonatomic, assign) id<ActionSheetViewDelegate> delegate;

+ (void) ShowActionSheetView:(UIView *)inView delegate:(id)delegate pos:(float)basePos title:(NSString *)title cancel:(NSString *)cancel buttons:(NSArray *)aryButtos red:(int)redIndex tag:(int)tag;

@end
