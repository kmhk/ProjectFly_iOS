//
//  MenuView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "MenuView.h"
#import "DataManager.h"

@interface MenuView()

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation MenuView

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    [self.backView addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    self.clipsToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onRate:(id)sender
{
    [self hideMenu];
    
    [self.delegate rateWithMenu:self];
}

- (IBAction)onFlyOfWeek:(id)sender
{
    [self hideMenu];
    
    [self.delegate flyOfWeekWithMenu:self];
}

- (IBAction)onNotifications:(id)sender
{
    [self hideMenu];
    
    [self.delegate notificationsWithMenu:self];
}

- (IBAction)onProfile:(id)sender
{
    [self hideMenu];
    
    [self.delegate profileWithMenu:self];
}

- (IBAction)onFavorites:(id)sender
{
    [self hideMenu];
    
    [self.delegate favoritesWithMenu:self];
}

- (IBAction)onUpload:(id)sender
{
    [self hideMenu];
    
    [self.delegate uploadWithMenu:self];
}

- (IBAction)onRules:(id)sender
{
    [self hideMenu];
    
    [self.delegate rulesWithMenu:self];
}

- (IBAction)onHelp:(id)sender
{
    [self hideMenu];
    
    [self.delegate helpWithMenu:self];
}

- (IBAction)onLinkWithFacebook:(id)sender
{
    [self hideMenu];
    
    [self.delegate linkWithFacebook:self];
}

- (IBAction)onLinkWithInstagram:(id)sender
{
    [self hideMenu];
    
    [self.delegate linkWithInstagram:self];
}

- (void) tapView
{
    [self hideMenu];
}

- (void) showMenu
{
    self.hidden = NO;
    self.menuView.frame = CGRectMake(0, 0, self.menuView.frame.size.width, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(0, 0, self.menuView.frame.size.width, [DataManager is6PlusScreen] ? 390 : 304);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) isShownMenu
{
    return self.menuView.frame.size.height > 0;
}

- (void) hideMenu
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(0, 0, self.menuView.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


@end
