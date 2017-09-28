//
//  ProfileExpandedViewController.m
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import "ProfileExpandedViewController.h"
#import "PostCollectionViewCell.h"
#import "ViewImageViewController.h"
#import <Parse/Parse.h>
#import <Facebook-iOS-SDK/FBSDKLoginKit/FBSDKLoginKit.h>
#import <Facebook-iOS-SDK/FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface ProfileExpandedViewController ()
{
    NSArray *arrayOfPhotos;
}

@property (weak, nonatomic) IBOutlet UIView *viewImages;
@property (weak, nonatomic) IBOutlet UICollectionView *cvImages;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivOccasion;

@property (weak, nonatomic) IBOutlet UIView *viewBottomInfo;

@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;

@property (weak, nonatomic) IBOutlet UIView *viewPhotos;
@property (weak, nonatomic) IBOutlet UIView *viewStarts;

@property (weak, nonatomic) IBOutlet UILabel *lblFirstnameAge;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotoCount;
@property (weak, nonatomic) IBOutlet UILabel *lblReceivedStarCount;
@property (weak, nonatomic) IBOutlet UILabel *lblReceivedRatingCount;

@end

@implementation ProfileExpandedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *cellNib = [UINib nibWithNibName:@"PostCollectionViewCell" bundle:nil];
    [self.cvImages registerNib:cellNib forCellWithReuseIdentifier:@"cell"];
    
    if (self.isOwner) {
        FBSDKProfile *currentFBProfile = [FBSDKProfile currentProfile];
        CGSize profileImageSize = CGSizeMake(self.ivProfile.frame.size.width * 3, self.ivProfile.frame.size.height * 3);
        NSString *profileImagePath = [currentFBProfile imagePathForPictureMode:FBSDKProfilePictureModeNormal size:profileImageSize];
        [self.ivProfile setImageWithURL:[NSURL URLWithString:profileImagePath relativeToURL:[NSURL URLWithString:@"http://graph.facebook.com/"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    } else {
        [self.ivProfile setImageWithURL:[NSURL URLWithString:[(PFFile *)self.pfoUser[@"profileImageLarge"] url]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    self.ivProfile.clipsToBounds = YES;
    
    self.viewPhotos.layer.cornerRadius = 5;
    self.viewPhotos.clipsToBounds = YES;
    
    self.viewStarts.layer.cornerRadius = 5;
    self.viewStarts.clipsToBounds = YES;
    
    arrayOfPhotos = [NSArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ViewImage"])
    {
        ViewImageViewController *vc = segue.destinationViewController;
        vc.imageObject = sender;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.cvImages reloadData];
    
    [self updateUI];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    [query whereKey:@"isDeleted" equalTo:[NSNumber numberWithBool:NO]];
    if (self.isOwner) {
        [query whereKey:@"uploader" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"uploader" equalTo:self.pfoUser];
    }
    
    switch (self.occasionIndex) {
        case 0:
            break;
        case 1:
            [query whereKey:@"fashionCategory" equalTo:@"Nightlife"];
            break;
        case 2:
            [query whereKey:@"fashionCategory" equalTo:@"Professional"];
            break;
        case 3:
            [query whereKey:@"fashionCategory" equalTo:@"Streetwear"];
            break;
        default:
            break;
    }
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            arrayOfPhotos = objects;
            self.lblPhotoCount.text = [NSString stringWithFormat:@"%d", (int)arrayOfPhotos.count];
            [self.cvImages reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateUI
{
    PFUser *parseUser;
    if (self.isOwner) {
        parseUser = [PFUser currentUser];
    } else {
        parseUser = self.pfoUser;
    }
    
    self.ivOccasion.hidden = NO;
    if(self.occasionIndex == 0)
    {
        self.ivOccasion.hidden = YES;
        self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s uploads", [parseUser objectForKey:@"appUsername"]];
    }
    else if(self.occasionIndex == 1)
    {
        self.ivOccasion.image = [UIImage imageNamed:@"common_icon_nightlife"];
        self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s nightlife uploads", [parseUser objectForKey:@"appUsername"]];
    }
    else if(self.occasionIndex == 2)
    {
        self.ivOccasion.image = [UIImage imageNamed:@"common_icon_professional"];
        self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s professional uploads", [parseUser objectForKey:@"appUsername"]];
    }
    else
    {
        self.ivOccasion.image = [UIImage imageNamed:@"common_icon_streetwear"];
        self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s streetwear uploads", [parseUser objectForKey:@"appUsername"]];
    }
    
    self.lblFirstnameAge.text = [NSString stringWithFormat:@"%@, %@", parseUser[@"firstName"], parseUser[@"age"]];
    self.lblLocation.text = parseUser[@"userLocation"];
    if (arrayOfPhotos.count == 0) {
        self.lblPhotoCount.text = @"";
    } else {
        self.lblPhotoCount.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrayOfPhotos.count];
    }
    self.lblReceivedStarCount.text = [NSString stringWithFormat:@"%d", [parseUser[@"metaData"][@"fiveStarsReceived"] intValue] * 5 + [parseUser[@"metaData"][@"fourStarsReceived"] intValue] * 4 + [parseUser[@"metaData"][@"threeStarsReceived"] intValue] * 3 + [parseUser[@"metaData"][@"twoStarsReceived"] intValue] * 2 + [parseUser[@"metaData"][@"oneStarReceived"] intValue] * 1];
    //self.lblReceivedRatingCount.text = [NSString stringWithFormat:@"%d RATINGS", [parseUser[@"metaData"][@"fiveStarsGiven"] intValue] * 5 + [parseUser[@"metaData"][@"fourStarsGiven"] intValue] * 4 + [parseUser[@"metaData"][@"threeStarsGiven"] intValue] * 3 + [parseUser[@"metaData"][@"twoStarsGiven"] intValue] * 2 + [parseUser[@"metaData"][@"oneStarGiven"] intValue] * 1];
    self.lblReceivedRatingCount.text = [NSString stringWithFormat:@"%d RATINGS", [parseUser[@"metaData"][@"nightRatedCount"] intValue] + [parseUser[@"metaData"][@"profRatedCount"] intValue] + [parseUser[@"metaData"][@"streetRatedCount"] intValue]];
}

- (void) hideBottomInfoView
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewImages.frame = CGRectMake(self.viewImages.frame.origin.x, self.viewImages.frame.origin.y, self.viewImages.frame.size.width, self.view.frame.size.height - self.viewImages.frame.origin.y);
        self.viewBottomInfo.frame = CGRectMake(self.viewBottomInfo.frame.origin.x, self.view.frame.size.height, self.viewBottomInfo.frame.size.width, self.viewBottomInfo.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) showBottomInfoView
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewImages.frame = CGRectMake(self.viewImages.frame.origin.x,
                                         self.viewImages.frame.origin.y,
                                         self.viewImages.frame.size.width,
                                         self.view.frame.size.height - self.viewImages.frame.origin.y - self.viewBottomInfo.frame.size.height);
        
        self.viewBottomInfo.frame = CGRectMake(self.viewBottomInfo.frame.origin.x,
                                               self.view.frame.size.height - self.viewBottomInfo.frame.size.height,
                                               self.viewBottomInfo.frame.size.width,
                                               self.viewBottomInfo.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) hiddenBottonInfoView
{
    return self.viewBottomInfo.frame.origin.y == self.view.frame.size.height;
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrayOfPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(PostCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.ivPost.image = [UIImage imageNamed:@"rate_image"];
    PFFile *mainImage = arrayOfPhotos[indexPath.row][@"mainImage"];
    [cell.ivPost setImageWithURL:[NSURL URLWithString:mainImage.url] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.lblDescription.hidden = YES;
    cell.ivIcon.hidden = YES;
    cell.ivBlackTriangle.hidden = YES;
    
    cell.viewMain.frame = CGRectMake(0, 0, (self.cvImages.frame.size.width) / 2, (self.cvImages.frame.size.width) / 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.cvImages.frame.size.width) / 2, (self.cvImages.frame.size.width) / 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ViewImage" sender:arrayOfPhotos[indexPath.row]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y > 0 && ![self hiddenBottonInfoView])
    {
        [self hideBottomInfoView];
    }
    
    if(scrollView.contentOffset.y < 0 && [self hiddenBottonInfoView])
    {
        [self showBottomInfoView];
    }
}

@end
