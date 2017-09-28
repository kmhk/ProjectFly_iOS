//
//  EditProfileView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EDIT_PROFILE_HEIGHT  190

@protocol EditProfileViewDelegate <NSObject>

- (void) doneEditProfile:(NSString *)username;
- (void) logout;

@end

@interface EditProfileView : UIView <UITextFieldDelegate>

@property (nonatomic, assign) id<EditProfileViewDelegate> delegate;

- (void) showMenu;
- (void) hideMenu;
- (BOOL) isShownMenu;

@end
