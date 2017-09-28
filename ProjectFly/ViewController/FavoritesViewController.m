//
//  FavoritesViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "FavoritesViewController.h"
#import "PostHeaderView.h"
#import "PostTableViewCell.h"
#import "ProfileViewController.h"
#import "TagView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface FavoritesViewController ()<UIActionSheetDelegate, PostHeaderViewDelegate, PostTableViewCellDelegate, TagViewDelegate>
{
    int _currentPageIndex;
    
    MBProgressHUD *hudLoading;
    
    BOOL _isNotLoadNew;
}

@property (weak, nonatomic) IBOutlet UITableView *tvImages;

@property (nonatomic, strong) NSMutableArray *aryImages;
@property (nonatomic, strong) NSMutableArray *aryFavorites;

@property (nonatomic, strong) NSMutableArray *aryPosts;
@property (nonatomic, strong) NSMutableArray *aryFavoritePosts;
@property (nonatomic, strong) NSMutableArray *aryShowTag;

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationIndex = 0;
    self.occasionIndex = 0;
    self.genderIndex = 0;
    
    UINib *cellNib = [UINib nibWithNibName:[DataManager getXibName:@"PostTableViewCell"] bundle:nil];
    [self.tvImages registerNib:cellNib forCellReuseIdentifier:@"cell"];
    
    hudLoading = [[MBProgressHUD alloc] initWithView:self.view];
    hudLoading.labelText = @"Loading";
    hudLoading.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudLoading];
    
    //[self initData];
    
    _isNotLoadNew = NO;
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

- (void) initData
{
    self.aryFavorites = [[NSMutableArray alloc] init];
    self.aryImages = [[NSMutableArray alloc] init];
    self.aryShowTag = [[NSMutableArray alloc] init];
    self.aryFavoritePosts = [[NSMutableArray alloc] init];
    
    [hudLoading show:YES];
    
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
    [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [favoriteQuery whereKey:@"isFavorite" equalTo:[NSNumber numberWithBool:YES]];
    if (self.genderIndex > 0) {
        [favoriteQuery whereKey:@"gender" equalTo:[genders[self.genderIndex] lowercaseString]];
    }
    if (self.locationIndex > 0) {
        [favoriteQuery whereKey:@"userLocation" hasPrefix:genders[self.locationIndex]];
    }
    if (self.occasionIndex > 0) {
        [favoriteQuery whereKey:@"fashionCategory" equalTo:occasions[self.occasionIndex]];
    }
    [favoriteQuery includeKey:@"image"];
    [favoriteQuery includeKey:@"image.uploader"];
    [favoriteQuery orderByDescending:@"createdAt"];
    
    [favoriteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.aryPosts = [NSMutableArray new];
            for (PFObject *favoriteObject in objects) {
                [self.aryFavoritePosts addObject:favoriteObject];
                PFObject *imageObject = favoriteObject[@"image"];
                [self.aryPosts addObject:imageObject];
                
                NSMutableDictionary *image = [NSMutableDictionary new];
                image[@"username"] = imageObject[@"uploader"][@"appUsername"];
                if (imageObject[@"uploader"][@"profileAvatarLarge"]) {
                    image[@"userProfileImageUrl"] = [(PFFile *)imageObject[@"uploader"][@"profileAvatarLarge"] url];
                } else {
                    image[@"userProfileImageUrl"] = @"";
                }
                //image[@"userProfileImageUrl"] = [(PFFile *)imageObject[@"uploader"][@"profileAvatarLarge"] url];
                image[@"imageUrl"] = [(PFFile *)imageObject[@"mainImage"] url];
                image[@"description"] = imageObject[@"caption"];
                image[@"location"] = [NSNumber numberWithInt:2];
                image[@"locationText"] = imageObject[@"uploader"][@"userLocation"];
                image[@"locationText"] = [image[@"locationText"] componentsSeparatedByString:@","][0];
                
                if ([imageObject[@"fashionCategory"] isEqualToString:@"Nightlife"]) {
                    image[@"occasion"] = [NSNumber numberWithInt:1];
                } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Professional"]) {
                    image[@"occasion"] = [NSNumber numberWithInt:2];
                } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Streetwear"]) {
                    image[@"occasion"] = [NSNumber numberWithInt:3];
                } else {
                    image[@"occasion"] = [NSNumber numberWithInt:0];
                }
                
                if ([imageObject[@"uploader"][@"gender"] isEqualToString:@"male"]) {
                    image[@"gender"] = [NSNumber numberWithInt:2];
                } else if ([imageObject[@"fashionCategory"] isEqualToString:@"female"]) {
                    image[@"gender"] = [NSNumber numberWithInt:1];
                } else {
                    image[@"gender"] = [NSNumber numberWithInt:0];
                }
                
                image[@"point"] = imageObject[@"currentRating"];
                image[@"viewer"] = [NSString stringWithFormat:@"%d Views", [imageObject[@"ratedCount"] intValue]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM d, yyyy"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                image[@"date"] = [NSString stringWithFormat:@"Uploaded %@", [dateFormatter stringFromDate:imageObject.createdAt]];
                image[@"4"] = imageObject[@"fourStarsReceived"];
                image[@"5"] = imageObject[@"fiveStarsReceived"];
                image[@"tags"] = imageObject[@"tags"];
                
                [self.aryImages addObject:image];
                [self.aryShowTag addObject:[NSNumber numberWithBool:NO]];
            }
            [self updateUI];
            
            [hudLoading hide:YES];
        }
    }];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.tvImages reloadData];
    
    if (!_isNotLoadNew) {
        [self initData];
    } else {
        _isNotLoadNew = NO;
    }
}

- (void) updateUI
{
    [self.tvImages reloadData];
}

- (void) onTag
{
    self.aryShowTag[_currentPageIndex] = [NSNumber numberWithBool:![self.aryShowTag[_currentPageIndex] boolValue]];
    
    [self.tvImages reloadData];
}

- (void) onSubmenu:(float) pos
{
    pos = self.view.frame.size.height - ([DataManager is6PlusScreen] ? 142 : 114);
    
    if(![self isFavoritedImage])
    {
        NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Flag Image", @"Favorite Photo", nil];
        [self showActionsheet:pos title:nil cancel:@"Cancel" buttons:aryButtons red:0 tag:0];
    }
    else
    {
        NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Flag Image", @"Unfavorite Photo", nil];
        [self showActionsheet:pos title:nil cancel:@"Cancel" buttons:aryButtons red:0 tag:1];
    }
}

- (BOOL) isFavoritedImage
{
    return YES;//[self.aryFavorites containsObject:[NSNumber numberWithInt:_currentPageIndex]];
}

- (void) favoriteCurrentImage
{
    if(![self.aryFavorites containsObject:[NSNumber numberWithInt:_currentPageIndex]])
    {
        [self.aryFavorites addObject:[NSNumber numberWithInt:_currentPageIndex]];
    }
}

- (void) unfavoriteCurrentImage
{
    if([self.aryFavorites containsObject:[NSNumber numberWithInt:_currentPageIndex]])
    {
    
    }
    [self.aryFavorites removeObject:[NSNumber numberWithInt:_currentPageIndex]];
    PFObject *favoriteObject = [self.aryFavoritePosts objectAtIndex:_currentPageIndex];
    [favoriteObject deleteInBackground];
    [self.aryFavoritePosts removeObjectAtIndex:_currentPageIndex];
    [self.aryPosts removeObjectAtIndex:_currentPageIndex];
    [self.aryImages removeObjectAtIndex:_currentPageIndex];
    [self updateUI];
}

- (void) gotoProfileScreen:(PFUser *)profileObject
{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.isOwner = NO;
    vc.pfoUser = profileObject;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.aryImages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tvImages.frame.size.height - ([DataManager is6PlusScreen] ? 96 : POST_HEADER_HEIGHT);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [DataManager is6PlusScreen] ? 96 : POST_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"PostHeaderView"] owner:nil options:nil];
    PostHeaderView *headerView = [nib objectAtIndex:0];
    headerView.delegate = self;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostTableViewCell *cell = (PostTableViewCell *)[self.tvImages dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PostTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.aryShowTag[indexPath.section] boolValue])
        [cell showTags];
    else
        [cell hideTags];
    
    //cell.viewMain.frame = CGRectMake(0, 0, self.cvImages.frame.size.width, [self getHeightCell]);
    cell.viewMain.frame = CGRectMake(0, 0, self.tvImages.frame.size.width, self.tvImages.frame.size.height - ([DataManager is6PlusScreen] ? 96 : POST_HEADER_HEIGHT));
    
    NSDictionary *imageInfo = [self.aryImages objectAtIndex:indexPath.section];
    
    cell.lblDescription.text = [imageInfo objectForKey:@"description"];
    
    cell.lblViewers.text = [NSString stringWithFormat:@"%@", [imageInfo objectForKey:@"viewer"]];
    cell.lblUploadedDate.text = [imageInfo objectForKey:@"date"];
    cell.lblFourMarks.text = [NSString stringWithFormat:@"%@", [imageInfo objectForKey:@"4"]];
    cell.lblFiveMarks.text = [NSString stringWithFormat:@"%@", [imageInfo objectForKey:@"5"]];
    
    [cell.ivImage setImageWithURL:[NSURL URLWithString:imageInfo[@"imageUrl"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    for (UIView *subview in cell.viewTags.subviews) {
        if ([subview isKindOfClass:[TagView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    for (NSDictionary *tag in imageInfo[@"tags"]) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"TagView"] owner:nil options:nil];
        TagView *tagView = [nib objectAtIndex:0];
        tagView.delegate = self;
        
        tagView.brand = tag[@"brand"];
        tagView.item = tag[@"item"];
        [tagView done:[NSString stringWithFormat:@"%@ %@", tag[@"brand"], tag[@"item"]]];
        tagView.center = CGPointMake([tag[@"positionX"] floatValue], [tag[@"positionY"] floatValue]);
        tagView.btnClose.hidden = YES;
        tagView.isMove = NO;
        
        [cell.viewTags addSubview:tagView];
    }
    
    cell.isFromFavoriteViewController = YES;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(PostHeaderView *)view forSection:(NSInteger)section
{
    _currentPageIndex = (int)section;
    
    NSDictionary *imageInfo = [self.aryImages objectAtIndex:section];
    
    //view.locationIndex = self.locationIndex;//[[imageInfo objectForKey:@"location"] intValue];
    //view.occasionIndex = self.occasionIndex;//[[imageInfo objectForKey:@"occasion"] intValue];
    //view.genderIndex = self.genderIndex;//[[imageInfo objectForKey:@"gender"] intValue];
    
    view.locationIndex = [[imageInfo objectForKey:@"location"] intValue];
    view.locationText = [imageInfo objectForKey:@"locationText"];
    view.occasionIndex = [[imageInfo objectForKey:@"occasion"] intValue];
    view.genderIndex = [[imageInfo objectForKey:@"gender"] intValue];
    
    [view updateFilterIcons];
    
    view.lblUsername.text = [imageInfo objectForKey:@"username"];
    [view.ivUserAvatar setImageWithURL:[NSURL URLWithString:imageInfo[@"userProfileImageUrl"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.ivUserAvatar.layer.cornerRadius = view.ivUserAvatar.frame.size.width / 2;
    view.ivUserAvatar.clipsToBounds = YES;
    view.lblMarks.text = [NSString stringWithFormat:@"%.2f", [[imageInfo objectForKey:@"point"] floatValue]];
    view.pfoUploader = [self.aryPosts[section] objectForKey:@"uploader"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark ActionSheetDelegate

- (void) onButtonClickWithActionsheet:(UIView *)actionSheetView index:(int)index
{
    if(actionSheetView.tag == 0)
    {
        if(index == 0)
        {
            [self showAlertView:nil message:@"The Fly Team has been notified!" cancel:@"Okay" ok:nil tag:0];
            [self flagCurrentImage];
        }
        else if(index == 1)
        {
            [self favoriteCurrentImage];
        }
    }
    else if(actionSheetView.tag == 1)
    {
        if(index == 0)
        {
            [self showAlertView:nil message:@"The Fly Team has been notified!" cancel:@"Okay" ok:nil tag:0];
            [self flagCurrentImage];
        }
        else if(index == 1)
        {
            [self unfavoriteCurrentImage];
        }
    }
}

- (void) flagCurrentImage {
    PFObject *imageObject = [self.aryPosts objectAtIndex:_currentPageIndex];
    imageObject[@"isFlagged"] = [NSNumber numberWithBool:YES];
    [imageObject saveInBackground];
}

#pragma mark PostHeaderViewDelegate

- (void) openUserProfileWithPostHeaderView:(PFUser *)uploader
{
    [self gotoProfileScreen:uploader];
    _isNotLoadNew = YES;
}

- (void) showTagWithPostTableViewCell
{
    [self onTag];
}

- (void) submenuWithPostTableViewCell:(float)pos
{
    [self onSubmenu:pos];
}

#pragma mark PostTableViewCellDelegate

- (void) likeWithImage:(NSDictionary *)image {
    ;
}

- (void) openImageWithPostTableViewCell:(UIImage *)image
{
    [self showLightBox:image];
    _isNotLoadNew = YES;
}

#pragma mark FilterViewDelegate

- (void) applyFilterOption
{
    self.occasionIndex = self.filterView.occasionIndex;
    self.locationIndex = self.filterView.locationIndex;
    self.genderIndex = self.filterView.genderIndex;
    
    [self initData];
    
    [self updateUI];
}

#pragma mark TagViewDelegate

- (void) closeTag:(UIView *)view
{
    /*if(_editingTagView == view)
     {
     [self hideEditTagView];
     }
     [arrayOfTagViews removeObject:view];*/
}

@end
