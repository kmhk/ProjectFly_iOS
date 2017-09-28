//
//  NotificationTableViewCell.h
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import <UIKit/UIKit.h>

#define NOTIFICATION_CELL_HEIGHT 72

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, assign) int type;

@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) IBOutlet UILabel *lblClickToMoreView;

- (void) setMoreButton:(BOOL)isMoreButton;

@end
