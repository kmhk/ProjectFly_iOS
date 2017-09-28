//
//  MenuView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate <NSObject>

- (void) rateWithMenu:(UIView *)menu;
- (void) flyOfWeekWithMenu:(UIView *)menu;
- (void) notificationsWithMenu:(UIView *)menu;
- (void) profileWithMenu:(UIView *)menu;
- (void) favoritesWithMenu:(UIView *)menu;
- (void) uploadWithMenu:(UIView *)menu;
- (void) rulesWithMenu:(UIView *)menu;
- (void) helpWithMenu:(UIView *)menu;

- (void) linkWithFacebook:(UIView *)menu;
- (void) linkWithInstagram:(UIView *)menu;

@end

@interface MenuView : UIView

@property (nonatomic, assign) id<MenuViewDelegate> delegate;

- (void) showMenu;
- (void) hideMenu;
- (BOOL) isShownMenu;

@end
