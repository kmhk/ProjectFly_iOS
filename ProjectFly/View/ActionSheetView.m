//
//  ActionSheetView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "ActionSheetView.h"

#import "DataManager.h"

#define ACTIONSHEET_ITEM_HEIGHT 28
#define ACTIONSHEET_ITEM_HEIGHT_6PLUS 45
#define ACTIONSHEET_ITEM_GAP 10

@interface ActionSheetView()
{
    float menuViewheight ;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivBack;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UILabel *lblMenuTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet UIView *viewButtons;
@property (weak, nonatomic) IBOutlet UIButton *btnButton1;
@property (weak, nonatomic) IBOutlet UIButton *btnButton2;
@property (weak, nonatomic) IBOutlet UIButton *btnButton3;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cancel;
@property (nonatomic, strong) NSArray  *aryButtons;

@property (nonatomic, assign) int redIndex;

@property (nonatomic, assign) float basePosition;

@end

@implementation ActionSheetView

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    [self.ivBack addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    menuViewheight = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void) ShowActionSheetView:(UIView *)inView delegate:(id)delegate pos:(float)basePos title:(NSString *)title cancel:(NSString *)cancel buttons:(NSArray *)aryButtos red:(int)redIndex tag:(int)tag
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"ActionSheetView"] owner:nil options:nil];
    ActionSheetView *actionSheet = [nib objectAtIndex:0];
    actionSheet.tag = tag;
    actionSheet.delegate = delegate;
    
    [inView addSubview:actionSheet];
    
    actionSheet.frame = CGRectMake(0, 0, inView.frame.size.width, inView.frame.size.height);

    actionSheet.title = title;
    actionSheet.cancel = cancel;
    actionSheet.aryButtons = aryButtos;
    actionSheet.redIndex = redIndex;
    
    actionSheet.basePosition = basePos;
    
    [actionSheet showMenu];
}

- (void) initView
{
    float pos = 0;
    
    if(self.title == nil)
    {
        self.lblMenuTitle.hidden = YES;
    }
    else
    {
        self.lblMenuTitle.hidden = NO;
        self.lblMenuTitle.text = self.title;
        
        pos += self.lblMenuTitle.frame.size.height;
    }
    
    self.viewButtons.frame = CGRectMake(0, pos, self.menuView.frame.size.width, self.aryButtons.count * ([DataManager is6PlusScreen] ? ACTIONSHEET_ITEM_HEIGHT_6PLUS : ACTIONSHEET_ITEM_HEIGHT));
    
    for (int n = 0 ; n < self.aryButtons.count ; n ++) {
        NSString *buttonTitle = [self.aryButtons objectAtIndex:n];
        UIButton *button = (UIButton *)[self.viewButtons viewWithTag:(n + 1)];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        
        if(n == self.redIndex)
        {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    pos += self.viewButtons.frame.size.height + ACTIONSHEET_ITEM_GAP;
    
    self.btnCancel.frame = CGRectMake(0, pos, self.btnCancel.frame.size.width, self.btnCancel.frame.size.height);
    [self.btnCancel setTitle:self.cancel forState:UIControlStateNormal];
    
    pos += self.btnCancel.frame.size.height;
    self.menuView.frame = CGRectMake(self.frame.size.width - self.menuView.frame.size.width, self.basePosition, self.menuView.frame.size.width, 0);
    
    menuViewheight = pos;
}

- (void) tapView
{
    [self hideMenu];
}

- (void) showMenu
{
    [self initView];
    
    self.hidden = NO;
    self.menuView.frame = CGRectMake(self.menuView.frame.origin.x, self.basePosition, self.menuView.frame.size.width, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(self.menuView.frame.origin.x, self.basePosition - menuViewheight, self.menuView.frame.size.width, menuViewheight);
        
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
        
        self.menuView.frame = CGRectMake(self.menuView.frame.origin.x, self.basePosition, self.menuView.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        [self removeFromSuperview];
    }];
}

- (IBAction)onCancel:(id)sender
{
    [self hideMenu];
}

- (IBAction)onButton:(id)sender
{
    int index = (int)((UIButton *)sender).tag - 1;
    
    [self.delegate onButtonClickWithActionsheet:self index:index];
    
    [self hideMenu];
}


@end
