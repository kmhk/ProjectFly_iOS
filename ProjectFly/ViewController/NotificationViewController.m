//
//  NotificationViewController.m
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import "NotificationViewController.h"

#import "NotificationTableViewCell.h"

@interface NotificationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tvNotifications;

@property (weak, nonatomic) IBOutlet UIButton *btnMore;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *cellNib = [UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil];
    [self.tvNotifications registerNib:cellNib forCellReuseIdentifier:@"NotificationTableViewCell"];
    
    self.btnMore.layer.borderColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f].CGColor;
    self.btnMore.layer.borderWidth = 1.0f;
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (IBAction)onMore:(id)sender
{
    
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 7)
        return NOTIFICATION_CELL_HEIGHT / 2;
    
    return NOTIFICATION_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(NotificationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 7)
        cell.viewMain.frame = CGRectMake(0, 0, self.tvNotifications.frame.size.width, NOTIFICATION_CELL_HEIGHT / 2);
    else
        cell.viewMain.frame = CGRectMake(0, 0, self.tvNotifications.frame.size.width, NOTIFICATION_CELL_HEIGHT);
    
    if(indexPath.section == 7)
    {
        cell.viewMain.backgroundColor = [UIColor whiteColor];
        
        cell.type = 3;
        
        [cell setMoreButton:YES];
    }
    else if(indexPath.section == 0 || indexPath.section == 6)
    {
        cell.viewMain.backgroundColor = [UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
        cell.lblMessage.textColor = [UIColor whiteColor];
        cell.ivImage.hidden = NO;
        cell.lblValue.hidden = YES;
        cell.lblMessage.text = @"100+ people have rated your picture. Tap here to see your ratings";
        
        cell.type = 0;
        
        [cell setMoreButton:NO];
    }
    else if(indexPath.section == 4)
    {
        cell.viewMain.backgroundColor = [UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
        cell.lblMessage.textColor = [UIColor whiteColor];
        cell.ivImage.hidden = NO;
        cell.ivImage.image = [UIImage imageNamed:@"common_icon_fly_white"];
        cell.lblValue.hidden = YES;
        cell.lblMessage.text = @"You have rated 20+ pictures and are now a Novice Viewer!";
        
        cell.type = 2;
        
        [cell setMoreButton:NO];
    }
    else
    {
        cell.viewMain.backgroundColor = [UIColor whiteColor];
        cell.lblMessage.textColor = [UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
        cell.ivImage.hidden = YES;
        cell.lblValue.hidden = NO;
        cell.lblMessage.text = @"100+ people have rated your picture. Tap here to see your ratings";
        
        cell.type = 1;
        
        [cell setMoreButton:NO];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell *notificationCell = (NotificationTableViewCell *)[self.tvNotifications cellForRowAtIndexPath:indexPath];
    
    if(notificationCell.type == 0)
    {
        [self flyOfWeekWithMenu:nil];
    }
    else if(notificationCell.type == 1)
    {
        [self performSegueWithIdentifier:@"ViewImage" sender:nil];
    }
    else if(notificationCell.type == 2)
    {
        [self profileWithMenu:nil];
    }
}

@end
