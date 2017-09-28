//
//  EditProfileView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "EditProfileView.h"
#import "DataManager.h"
#import <Parse/Parse.h>

@interface EditProfileView()

@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;

@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@end

@implementation EditProfileView

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    self.clipsToBounds = YES;
    
    self.txtUsername.layer.cornerRadius = 3;
    self.txtUsername.layer.borderWidth = 1;
    self.txtUsername.layer.borderColor = [UIColor colorWithRed:201.f / 255.0f green:201.f / 255.0f blue:201.f / 255.0f alpha:1.0f].CGColor;
    self.txtUsername.text = [[PFUser currentUser] objectForKey:@"appUsername"];
    
    self.txtEmail.layer.cornerRadius = 3;
    self.txtEmail.layer.borderWidth = 1;
    self.txtEmail.layer.borderColor = [UIColor colorWithRed:201.f / 255.0f green:201.f / 255.0f blue:201.f / 255.0f alpha:1.0f].CGColor;
    self.txtEmail.text = [[PFUser currentUser] objectForKey:@"email"];
    
    self.txtLocation.layer.cornerRadius = 3;
    self.txtLocation.layer.borderWidth = 1;
    self.txtLocation.layer.borderColor = [UIColor colorWithRed:201.f / 255.0f green:201.f / 255.0f blue:201.f / 255.0f alpha:1.0f].CGColor;
    self.txtLocation.text = [[PFUser currentUser] objectForKey:@"userLocation"];
    
    self.btnLogout.layer.cornerRadius = 1;
    self.btnLogout.layer.borderWidth = 1;
    self.btnLogout.layer.borderColor = [UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f].CGColor;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onDone:(id)sender
{
    PFUser *parseCurrentUser = [PFUser currentUser];
    parseCurrentUser[@"appUsername"] = self.txtUsername.text;
    parseCurrentUser[@"userLocation"] = self.txtLocation.text;
    [parseCurrentUser saveInBackground];
    
    [self hideMenu];
    
    [self.delegate doneEditProfile:@"username"];
}

- (IBAction)onLogout:(id)sender
{
    [self.delegate logout];
}

- (void) tapView
{
    [self onDone:nil];
}

- (void) showMenu
{
    self.hidden = NO;
    self.menuView.frame = CGRectMake(0, [DataManager is6PlusScreen] ? 134 : 96, self.frame.size.width, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(0, [DataManager is6PlusScreen] ? 134 : 96, self.frame.size.width, [DataManager is6PlusScreen] ? 250 : EDIT_PROFILE_HEIGHT);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) isShownMenu
{
    return self.menuView.frame.size.height > 0;
}

- (void) hideMenu
{
    [self closeKeyboard];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(0, [DataManager is6PlusScreen] ? 134 : 96, self.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void) closeKeyboard
{
    [self.txtUsername resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtLocation resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtUsername)
    {
        [self.txtLocation becomeFirstResponder];
    }
    else
    {
        [self closeKeyboard];
    }
    
    /*
    if(textField == self.txtUsername)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if(textField == self.txtEmail)
    {
        [self.txtLocation becomeFirstResponder];
    }
    else
    {
        [self closeKeyboard];
    }*/
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.txtEmail) {
        return NO;
    } else {
        return YES;
    }
}

@end
