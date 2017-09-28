//
//  PostCollectionViewCell.h
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import <UIKit/UIKit.h>

@interface PostCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UIImageView *ivPost;
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivBlackTriangle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end
