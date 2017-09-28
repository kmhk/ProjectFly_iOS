//
//  BaseViewController.h
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import <UIKit/UIKit.h>

#import "MenuView.h"
#import "FilterView.h"

#import "DataManager.h"

#define TOP_BAR_HEIGHT 54

@interface BaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) MenuView *menuView;
@property (weak, nonatomic) FilterView *filterView;

- (IBAction)onMenu:(id)sender;
- (IBAction)onFilter:(id)sender;

- (void) showMenu;
- (void) hideMenu;
- (BOOL) isShownMenu;

- (void) showFilterMenu;
- (void) hideFilterMenu;
- (BOOL) isShownFilterMenu;

- (void) flyOfWeekWithMenu:(UIView *)menu;
- (void) profileWithMenu:(UIView *)menu;

- (void) showActionsheet:(float)basePos title:(NSString *)title cancel:(NSString *)cancel buttons:(NSArray *)aryButtons red:(int)redIndex tag:(int)tag;
- (void) showAlertView:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok tag:(int)tag;

- (void) showLightBox:(UIImage *)image;

- (void) onOkWithAlertView:(UIView *)alertView;
- (void) onCancelWithAlertView:(UIView *)alertView;

@end
