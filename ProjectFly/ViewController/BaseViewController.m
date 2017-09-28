//
//  BaseViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "BaseViewController.h"
#import "FlyWeekViewController.h"
#import "RateViewController.h"
#import "ProfileViewController.h"
#import "FavoritesViewController.h"
#import "UploadViewController.h"
#import "BlankViewController.h"
#import "NotificationViewController.h"
#import "LightBoxViewController.h"
#import "ActionSheetView.h"
#import "AlertView.h"
#import "DataManager.h"
#import "InstagramLoginViewController.h"
#import <Parse/Parse.h>

@interface BaseViewController ()<MenuViewDelegate, FilterViewDelegate, AlertViewDelegate>
{
    int _navHeight;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _navHeight = [DataManager is6PlusScreen] ? 82 : TOP_BAR_HEIGHT;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        [[PFUser currentUser][@"metaData"] fetchIfNeededInBackground];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onMenu:(id)sender
{
    if([self isShownFilterMenu])
    {
        [self hideFilterMenu];
    }
    
    if([self isShownMenu])
        [self hideMenu];
    else
        [self showMenu];
}

- (IBAction)onFilter:(id)sender
{
    if([self isShownMenu])
    {
        [self hideMenu];
    }
    
    if([self isShownFilterMenu])
        [self hideFilterMenu];
    else
        [self showFilterMenu];
}

- (void) showMenu
{
    if(self.menuView == nil)
    {        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"MenuView"] owner:nil options:nil];
        MenuView *menuView = [nib objectAtIndex:0];
        menuView.delegate = self;
        
        [self.view addSubview:menuView];
        self.menuView = menuView;
    }
    
    self.menuView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight);
    [self.view bringSubviewToFront:self.menuView];
    
    [self.menuView showMenu];
}

- (void) hideMenu
{
    [self.menuView hideMenu];
}

- (BOOL) isShownMenu
{
    return [self.menuView isShownMenu];
}

- (void) showFilterMenu
{
    if(self.filterView == nil)
    {        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"FilterView"] owner:nil options:nil];
        FilterView *filterView = [nib objectAtIndex:0];
        filterView.delegate = self;
        
        [self.view addSubview:filterView];
        self.filterView = filterView;
    }
    
    self.filterView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight);
    [self.view bringSubviewToFront:self.filterView];
    
    [self.filterView showMenu];
}

- (void) hideFilterMenu
{
    [self.filterView hideMenu];
}

- (BOOL) isShownFilterMenu
{
    return [self.filterView isShownMenu];
}

#pragma mark MenuViewDelegate

- (void) rateWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[RateViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    RateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RateViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) flyOfWeekWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[FlyWeekViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    FlyWeekViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FlyWeekViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) notificationsWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[NotificationViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    NotificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) profileWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[ProfileViewController class]])
        {
            ((ProfileViewController *)vc).isOwner = YES;
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.isOwner = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) favoritesWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[FavoritesViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    FavoritesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) uploadWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[UploadViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    UploadViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) rulesWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[BlankViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    BlankViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BlankViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) helpWithMenu:(UIView *)menu
{
    NSArray *aryVCs = self.navigationController.viewControllers;
    for (UIViewController *vc in aryVCs) {
        
        if([vc isKindOfClass:[BlankViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            
            return ;
        }
    }
    
    BlankViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BlankViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) linkWithFacebook:(UIView *)menu
{
    [self showAlertView:nil message:@"Link your Facebook to Fly?" cancel:@"Go Back" ok:@"Continue" tag:1000];
}

- (void) linkWithInstagram:(UIView *)menu
{
    [self showAlertView:nil message:@"Link your Instagram to Fly?" cancel:@"Go Back" ok:@"Continue" tag:1001];
}

- (void) showActionsheet:(float)basePos title:(NSString *)title cancel:(NSString *)cancel buttons:(NSArray *)aryButtons red:(int)redIndex tag:(int)tag
{
    [ActionSheetView ShowActionSheetView:self.view delegate:self pos:basePos title:title cancel:cancel buttons:aryButtons red:redIndex tag:tag];
}

- (void) showAlertView:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok tag:(int)tag
{
    [AlertView ShowAlertView:self.view delegate:self title:title message:message cancel:cancel ok:ok tag:tag];
}

- (void) showLightBox:(UIImage *)image
{
    LightBoxViewController *lightBoxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LightBoxViewController"];
    lightBoxVC.image = image;
    
    [self.navigationController presentViewController:lightBoxVC animated:YES completion:nil];
}

#pragma mark AlertViewDelegate

- (void) onOkWithAlertView:(UIView *)alertView
{
    if (alertView.tag == 1001) {
        InstagramLoginViewController *instagramLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InstagramLoginViewController"];
        
        [self.navigationController presentViewController:instagramLoginVC animated:YES completion:nil];
    }
}

- (void) onCancelWithAlertView:(UIView *)alertView
{
    
}

#pragma mark FilterViewDelegate

- (void) applyFilterOption {
    
}

@end
