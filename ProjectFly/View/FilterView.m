//
//  MenuView.m
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import "FilterView.h"

#import "MenuTableViewCell.h"

#import "DataManager.h"

#define DROPLIST_ITEM_HEIGHT  40

@interface FilterView()
{
    int _currentShowingDropListIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivBack;

@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UITableView *tvMenu;

@property (weak, nonatomic) IBOutlet UIView *viewDroplist1;
@property (weak, nonatomic) IBOutlet UIView *viewDroplist2;
@property (weak, nonatomic) IBOutlet UIView *viewDroplist3;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectedOccasion;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedGender;

@property (weak, nonatomic) IBOutlet UIImageView *ivOccasionIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivLocationIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivGenderIcon;

@end

@implementation FilterView

- (void) awakeFromNib
{
    _currentShowingDropListIndex = -1;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    [self.ivBack addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    self.clipsToBounds = YES;
    
    UINib *cellNib = [UINib nibWithNibName:@"MenuTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tvMenu registerNib:cellNib forCellReuseIdentifier:@"MenuCell"];
    
    self.tvMenu.frame = CGRectZero;
    
    self.ivLocationIcon.layer.cornerRadius = CGRectGetWidth(self.ivLocationIcon.frame) / 2;
    self.ivLocationIcon.clipsToBounds = YES;
    self.ivLocationIcon.backgroundColor = [UIColor colorWithRed:51.0f / 255.0f green:102.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onApply:(id)sender
{
    [self hideMenu];
    
    [self.delegate applyFilterOption];
}

- (IBAction)onOccasionDroplist:(id)sender
{
    if(_currentShowingDropListIndex == 0)
    {
        _currentShowingDropListIndex = -1;
        [self hideDroplist:nil];
    }
    else
    {
        _currentShowingDropListIndex = 0;
        
        if([self isShownDroplist])
        {
            [self hideDroplist:^(void) {
                [self showDroplist:sender];
            }];
            
            return;
        }
        
        [self showDroplist:sender];
    }
}

- (IBAction)onLocationDroplist:(id)sender
{
    if(_currentShowingDropListIndex == 1)
    {
        _currentShowingDropListIndex = -1;
        [self hideDroplist:nil];
    }
    else
    {
        _currentShowingDropListIndex = 1;
        
        if([self isShownDroplist])
        {
            [self hideDroplist:^(void) {
                [self showDroplist:sender];
            }];
            
            return;
        }
        
        [self showDroplist:sender];
    }
}

- (IBAction)onGenderDroplist:(id)sender
{
    if(_currentShowingDropListIndex == 2)
    {
        _currentShowingDropListIndex = -1;
        [self hideDroplist:nil];
    }
    else
    {
        _currentShowingDropListIndex = 2;
        
        if([self isShownDroplist])
        {
            [self hideDroplist:^(void) {
                [self showDroplist:sender];
            }];
            
            return;
        }
        
        [self showDroplist:sender];
    }
}

- (void) tapView
{
    if([self isShownDroplist])
    {
        _currentShowingDropListIndex = -1;
        [self hideDroplist:nil];
        
        return;
    }
    
    [self hideMenu];
}

- (void) showMenu
{
    [self updateUI];
    
    [self.tvMenu reloadData];
    
    self.hidden = NO;
    self.menuView.frame = CGRectMake(self.frame.size.width - self.menuView.frame.size.width, 0, self.menuView.frame.size.width, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(self.frame.size.width - self.menuView.frame.size.width, 0, self.menuView.frame.size.width, [DataManager is6PlusScreen] ? 310 : 238);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) isShownMenu
{
    return self.menuView.frame.size.height > 0;
}

- (void) hideMenu
{
    if([self isShownDroplist])
    {
        [self hideDroplist:^(void) {
            [self hideMenu];
        }];
        
        return ;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.menuView.frame = CGRectMake(self.frame.size.width - self.menuView.frame.size.width, 0, self.menuView.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void) showDroplist:(UIButton *)button
{
    CGPoint point = CGPointZero;
    float width = 0;
    float height = 0;
    float menuHeight = DROPLIST_ITEM_HEIGHT * SIZE_OCCASIONS;
    if(button.tag == 0)
    {
        point = self.viewDroplist1.frame.origin;
        width = self.viewDroplist1.frame.size.width;
        height = self.viewDroplist1.frame.size.height;
        
        menuHeight = DROPLIST_ITEM_HEIGHT * SIZE_OCCASIONS;
        
    } else if(button.tag == 1)
    {
        point = self.viewDroplist2.frame.origin;
        width = self.viewDroplist2.frame.size.width;
        height = self.viewDroplist2.frame.size.height;
        
        menuHeight = DROPLIST_ITEM_HEIGHT * SIZE_LOCATIONS;
    } else if(button.tag == 2)
    {
        point = self.viewDroplist3.frame.origin;
        width = self.viewDroplist3.frame.size.width;
        height = self.viewDroplist3.frame.size.height;
        
        menuHeight = DROPLIST_ITEM_HEIGHT * SIZE_GENDERS;
    }

    point = CGPointMake(point.x + self.menuView.frame.origin.x, point.y + self.menuView.frame.origin.y + height);
    
    self.tvMenu.frame = CGRectMake(point.x, point.y, width, 0);
    
    [self.tvMenu reloadData];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.tvMenu.frame = CGRectMake(point.x, point.y, width, menuHeight);
    } completion:^(BOOL finished) {
        //[self.tvMenu reloadData];
    }];
}

- (void) hideDroplist:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3f animations:^{
        self.tvMenu.frame = CGRectMake(self.tvMenu.frame.origin.x, self.tvMenu.frame.origin.y, self.tvMenu.frame.size.width, 0);
    } completion:^(BOOL finished) {
        
        if(completion != nil) completion();
    }];
}

- (BOOL) isShownDroplist
{
    return self.tvMenu.frame.size.height > 0;
}

- (void) updateUI
{
    float rightGap = [DataManager is6PlusScreen] ? 34 : 25;
    
    self.lblSelectedOccasion.text = occasions[self.occasionIndex];
    self.lblSelectedLocation.text = locations[self.locationIndex];
    self.lblSelectedGender.text = genders[self.genderIndex];
    
    [self.lblSelectedOccasion sizeToFit];
    self.lblSelectedOccasion.center = CGPointMake(self.viewDroplist1.frame.size.width - rightGap - self.lblSelectedOccasion.frame.size.width / 2, self.viewDroplist1.frame.size.height / 2);
    self.ivOccasionIcon.center = CGPointMake(self.viewDroplist1.frame.size.width - rightGap * 1.5 - self.lblSelectedOccasion.frame.size.width, self.viewDroplist1.frame.size.height / 2);
    
    [self.lblSelectedLocation sizeToFit];
    self.lblSelectedLocation.center = CGPointMake(self.viewDroplist2.frame.size.width - rightGap - self.lblSelectedLocation.frame.size.width / 2, self.viewDroplist2.frame.size.height / 2);
    self.ivLocationIcon.center = CGPointMake(self.viewDroplist2.frame.size.width - rightGap * 1.5 - self.lblSelectedLocation.frame.size.width, self.viewDroplist2.frame.size.height / 2);
    
    [self.lblSelectedGender sizeToFit];
    self.lblSelectedGender.center = CGPointMake(self.viewDroplist3.frame.size.width - rightGap - self.lblSelectedGender.frame.size.width / 2, self.viewDroplist3.frame.size.height / 2);
    self.ivGenderIcon.center = CGPointMake(self.viewDroplist3.frame.size.width - rightGap * 1.5 - self.lblSelectedGender.frame.size.width, self.viewDroplist3.frame.size.height / 2);

    
    self.ivOccasionIcon.hidden = NO;
    if(self.occasionIndex == 0)
    {
        self.ivOccasionIcon.hidden = YES;
    }
    else if(self.occasionIndex == 1)
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_nightlife"];
    }
    else if(self.occasionIndex == 2)
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_professional"];
    }
    else
    {
        self.ivOccasionIcon.image = [UIImage imageNamed:@"common_icon_streetwear"];
    }
    
    self.ivGenderIcon.hidden = NO;
    if(self.genderIndex == 0)
    {
        self.ivGenderIcon.hidden = YES;
    }
    else if(self.genderIndex == 1)
    {
        self.ivGenderIcon.image = [UIImage imageNamed:@"common_icon_female"];
    }
    else if(self.genderIndex == 2)
    {
        self.ivGenderIcon.image = [UIImage imageNamed:@"common_icon_male"];
    }
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_currentShowingDropListIndex == 0)
        return SIZE_OCCASIONS;
    
    if(_currentShowingDropListIndex == 1)
        return SIZE_LOCATIONS;
    
    return SIZE_GENDERS;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DROPLIST_ITEM_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    if(_currentShowingDropListIndex == 0)
    {
        cell.lblText.text = occasions[indexPath.row];
    }
    else if(_currentShowingDropListIndex == 1)
    {
        cell.lblText.text = locations[indexPath.row];
    }
    else if(_currentShowingDropListIndex == 2)
    {
        cell.lblText.text = genders[indexPath.row];
    }
    
    cell.lblText.frame = CGRectMake(10, 0, self.tvMenu.frame.size.width - 20, 30);
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_currentShowingDropListIndex == 0)
    {
        self.occasionIndex = (int)indexPath.row;
    }
    else if(_currentShowingDropListIndex == 1)
    {
        self.locationIndex = (int)indexPath.row;
    }
    else if(_currentShowingDropListIndex == 2)
    {
        self.genderIndex = (int)indexPath.row;
    }
    
    [self updateUI];
    
    _currentShowingDropListIndex = -1;
    [self hideDroplist:nil];
}


@end
