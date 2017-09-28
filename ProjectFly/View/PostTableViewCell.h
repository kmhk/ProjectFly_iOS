//
//  PostTableViewCell.h
//  Fly
//
//  Created by han on 3/8/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol PostTableViewCellDelegate <NSObject>

- (void) openImageWithPostTableViewCell:(UIImage *)image;
- (void) showTagWithPostTableViewCell;
- (void) submenuWithPostTableViewCell:(float)pos;
- (void) likeWithImage:(NSDictionary *)image;

@end

@interface PostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UIImageView *ivImage;

@property (weak, nonatomic) IBOutlet UIView *viewImage;
@property (weak, nonatomic) IBOutlet UIView *viewTags;
@property (weak, nonatomic) IBOutlet UIImageView *ivTags;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UILabel *lblViewers;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadedDate;
@property (weak, nonatomic) IBOutlet UILabel *lblFourMarks;
@property (weak, nonatomic) IBOutlet UILabel *lblFiveMarks;

@property (nonatomic) BOOL isFromFavoriteViewController;

@property (weak, nonatomic) PFObject *imageObject;

@property (nonatomic, assign) id<PostTableViewCellDelegate> delegate;

- (void) showTags;
- (void) hideTags;

@end