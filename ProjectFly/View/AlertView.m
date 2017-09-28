//
//  AlertView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "AlertView.h"

#import "DataManager.h"

#define ALERTVIEW_BUTTON_MIN_WIDTH 94
#define ALERTVIEW_BUTTON_MIN_WIDTH_6PLUS 120
#define ALERTVIEW_BUTTON_MAX_WIDTH 136

@interface AlertView()
{

}

@property (weak, nonatomic) IBOutlet UIImageView *ivBack;

@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancel;
@property (nonatomic, strong) NSString *ok;

@end

@implementation AlertView

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    [self.ivBack addGestureRecognizer:tapGesture];
    tapGesture = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void) ShowAlertView:(UIView *)inView delegate:(id)delegate title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok tag:(int)tag
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"AlertView"] owner:nil options:nil];
    AlertView *alertView = [nib objectAtIndex:0];
    alertView.tag = tag;
    alertView.delegate = delegate;
    
    [inView addSubview:alertView];
    
    alertView.frame = CGRectMake(0, 0, inView.frame.size.width, inView.frame.size.height);

    alertView.title = title;
    alertView.message = message;
    alertView.cancel = cancel;
    alertView.ok = ok;
    
    [alertView showMenu];
}

- (void) initView
{
    float buttonWidth = [DataManager is6PlusScreen] ? ALERTVIEW_BUTTON_MIN_WIDTH_6PLUS : ALERTVIEW_BUTTON_MIN_WIDTH;
    
    CGSize szMessage = [self.message sizeWithFont:self.lblMessage.font forWidth:self.lblMessage.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
    
    if(szMessage.height > 40)
    {
        self.messageView.frame = CGRectMake(self.messageView.frame.origin.x, self.messageView.frame.origin.y, self.messageView.frame.size.width, [DataManager is6PlusScreen] ? 180 : 160);
    }
    else
    {
        self.messageView.frame = CGRectMake(self.messageView.frame.origin.x, self.messageView.frame.origin.y, self.messageView.frame.size.width, [DataManager is6PlusScreen] ? 160 : 110);
    }
    
    self.lblMessage.text = self.message;
    
    if(self.ok != nil)
    {
        self.btnOk.hidden = NO;
        
        [self.btnCancel setTitle:self.cancel forState:UIControlStateNormal];
        [self.btnOk setTitle:self.ok forState:UIControlStateNormal];
        
        self.btnCancel.frame = CGRectMake((self.messageView.frame.size.width - buttonWidth * 2 - 10) / 2,
                                          self.btnCancel.frame.origin.y,
                                          buttonWidth,
                                          self.btnCancel.frame.size.height);
        
        self.btnOk.frame = CGRectMake((self.messageView.frame.size.width + 10) / 2,
                                          self.btnOk.frame.origin.y,
                                          buttonWidth,
                                          self.btnOk.frame.size.height);
    }
    else
    {
        self.btnOk.hidden = YES;
        
        [self.btnCancel setTitle:self.cancel forState:UIControlStateNormal];
        
        self.btnCancel.frame = CGRectMake((self.messageView.frame.size.width - ALERTVIEW_BUTTON_MAX_WIDTH) / 2,
                                          self.btnCancel.frame.origin.y,
                                          ALERTVIEW_BUTTON_MAX_WIDTH,
                                          self.btnCancel.frame.size.height);
    }
    
}

- (void) tapView
{
    [self hideMenu];
}

- (void) showMenu
{
    [self initView];
    
    self.hidden = NO;
    self.messageView.alpha = 0.0f;
    
    self.messageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    [UIView animateWithDuration:0.0f animations:^{
        
        self.messageView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideMenu
{
    [UIView animateWithDuration:0.0f animations:^{
    
        self.messageView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        [self removeFromSuperview];
    }];
}

- (IBAction)onCancel:(id)sender
{
    [self hideMenu];
    
    [self.delegate onCancelWithAlertView:self];
}

- (IBAction)onOk:(id)sender
{
    [self hideMenu];
    
    [self.delegate onOkWithAlertView:self];
}


@end
