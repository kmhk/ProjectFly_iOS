//
//  ProfileViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "ProfileViewController.h"
#import "ProfileExpandedViewController.h"
#import "PostCollectionViewCell.h"
#import "EditProfileView.h"
#import "FXBlurView.h"
#import <Parse/Parse.h>
#import <Facebook-iOS-SDK/FBSDKLoginKit/FBSDKLoginKit.h>
#import <Facebook-iOS-SDK/FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ProfileViewController ()<EditProfileViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *categoryObjects;
    MBProgressHUD *hudLoading;
}
@property (weak, nonatomic) IBOutlet UIView *viewImages;
@property (weak, nonatomic) IBOutlet UICollectionView *cvImages;
@property (weak, nonatomic) IBOutlet FXBlurView *viewBlur;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnEditProfileImage;

@property (weak, nonatomic) IBOutlet UIView *viewMainDetail;

@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;

@property (weak, nonatomic) IBOutlet UIView *viewPhotos;
@property (weak, nonatomic) IBOutlet UIView *viewStarts;

@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;

@property (weak, nonatomic) IBOutlet UILabel *lblFirstnameAge;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotoCount;
@property (weak, nonatomic) IBOutlet UILabel *lblReceivedStarCount;
@property (weak, nonatomic) IBOutlet UILabel *lblReceivedRatingCount;

@property (weak, nonatomic) EditProfileView *editProfileView;

@end

@implementation ProfileViewController

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
    
    self.viewBlur.blurRadius = 4;
    self.viewBlur.hidden = YES;
    
    self.btnRight.hidden = YES;
    
    hudLoading = [[MBProgressHUD alloc] initWithView:self.view];
    hudLoading.labelText = @"Loading";
    hudLoading.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudLoading];
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
    
    if([segue.identifier isEqualToString:@"ProfileExpanded"])
    {
        ProfileExpandedViewController *vc = segue.destinationViewController;
        vc.occasionIndex = [sender[@"occasionIndex"] intValue];
        vc.isOwner = [sender[@"isOwner"] boolValue];
        vc.pfoUser = sender[@"userProfileObject"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initView];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    BOOL isLoggedIn = [prefs boolForKey:@"LoggedIn"];
    
    if(!isLoggedIn)
    {
        [prefs setBool:YES forKey:@"LoggedIn"];
        [prefs synchronize];
        
        [self onPopmenu:nil];
    }
    
    [self updateUI];
    
    categoryObjects = nil;
    
    if (!categoryObjects) {
        categoryObjects = [NSMutableArray new];
        for (int i = 0; i < 3; i++) {
            [categoryObjects addObject:@""];
        }
    }
    
    NSInteger numberOfCategoriesToShow = 0;
    for (int i = 0; i < 3; i++) {
        if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
            numberOfCategoriesToShow++;
        }
    }
    if (numberOfCategoriesToShow == 3) {
        //return;
    }
    
    [hudLoading show:YES];
    
    __block int numberOfLoadedCategories = 0;
    
    for (int i = 0; i < 3; i++) {
        if (![categoryObjects[i] isKindOfClass:[PFObject class]]) {
            NSString *category;
            switch (i) {
                case 0:
                    category = @"Nightlife";
                    break;
                    
                case 1:
                    category = @"Professional";
                    break;
                    
                case 2:
                    category = @"Streetwear";
                    break;
                    
                default:
                    break;
            }
            
            PFQuery *query = [PFQuery queryWithClassName:@"Image"];
            [query whereKey:@"isDeleted" equalTo:[NSNumber numberWithBool:NO]];
            if (self.isOwner) {
                [query whereKey:@"uploader" equalTo:[PFUser currentUser]];
            } else {
                [query whereKey:@"uploader" equalTo:self.pfoUser];
            }
            [query whereKey:@"fashionCategory" equalTo:category];
            [query orderByDescending:@"updatedAt"];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    int index = 0;
                    if ([object[@"fashionCategory"] isEqualToString:@"Nightlife"]) {
                        index = 0;
                    } else if ([object[@"fashionCategory"] isEqualToString:@"Professional"]) {
                        index = 1;
                    } else if ([object[@"fashionCategory"] isEqualToString:@"Streetwear"]) {
                        index = 2;
                    }
                    categoryObjects[index] = object;
                } else {
                    // Log details of the failure
                    //NSLog(@"Error: %@ %@", error, [error userInfo]);
                    NSLog(@"No images for category :%@", category);
                }
                
                numberOfLoadedCategories++;
                if (numberOfLoadedCategories >= 3) {
                    [self.cvImages reloadData];
                    [hudLoading hide:YES];
                }
            }];
        } else {
            numberOfLoadedCategories++;
            if (numberOfLoadedCategories >= 3) {
                [self.cvImages reloadData];
                [hudLoading hide:YES];
            }
        }
    }
}

- (void) updateUI
{
    PFUser *parseUser;
    if (self.isOwner) {
        parseUser = [PFUser currentUser];
    } else {
        parseUser = self.pfoUser;
    }
    self.lblFirstnameAge.text = [NSString stringWithFormat:@"%@, %@", parseUser[@"firstName"], parseUser[@"age"]];
    self.lblLocation.text = parseUser[@"userLocation"];
    self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s Profile", [parseUser objectForKey:@"appUsername"]];
    self.lblPhotoCount.text = [NSString stringWithFormat:@"%d", [parseUser[@"metaData"][@"uploadCount"] intValue]];
    self.lblReceivedStarCount.text = [NSString stringWithFormat:@"%d", [parseUser[@"metaData"][@"fiveStarsReceived"] intValue] * 5 + [parseUser[@"metaData"][@"fourStarsReceived"] intValue] * 4 + [parseUser[@"metaData"][@"threeStarsReceived"] intValue] * 3 + [parseUser[@"metaData"][@"twoStarsReceived"] intValue] * 2 + [parseUser[@"metaData"][@"oneStarReceived"] intValue] * 1];
    //self.lblReceivedRatingCount.text = [NSString stringWithFormat:@"%d RATINGS", [parseUser[@"metaData"][@"fiveStarsGiven"] intValue] * 5 + [parseUser[@"metaData"][@"fourStarsGiven"] intValue] * 4 + [parseUser[@"metaData"][@"threeStarsGiven"] intValue] * 3 + [parseUser[@"metaData"][@"twoStarsGiven"] intValue] * 2 + [parseUser[@"metaData"][@"oneStarGiven"] intValue] * 1];
    self.lblReceivedRatingCount.text = [NSString stringWithFormat:@"%d RATINGS", [parseUser[@"metaData"][@"nightRatedCount"] intValue] + [parseUser[@"metaData"][@"profRatedCount"] intValue] + [parseUser[@"metaData"][@"streetRatedCount"] intValue]];
}

- (void) initView
{
    if(self.isOwner)
    {
        self.viewLine.hidden = NO;
        
        [self.btnEditProfile setTitle:@"" forState:UIControlStateNormal];
        [self.btnEditProfile setImage:[UIImage imageNamed:@"profile_btn_pop"] forState:UIControlStateNormal];
    }
    else
    {
        self.viewLine.hidden = YES;
        
        self.btnEditProfile.layer.borderColor = [UIColor colorWithRed:163.0f / 255.0f green:163.0f / 255.0f blue:163.0f / 255.0f alpha:1.0f].CGColor;
        self.btnEditProfile.layer.borderWidth = 1.0f;
        
        self.btnEditProfile.selected = YES;
        
        [self.btnEditProfile setTitle:@"+Subscribe" forState:UIControlStateNormal];
        [self.btnEditProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnEditProfile setBackgroundColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f]];
    }
    
    [self stopEditingProfile];
    
    if(!self.isOwner)
    {
        [self.btnLeft setImage:[UIImage imageNamed:@"common_btn_back"] forState:UIControlStateNormal];
        self.btnRight.hidden = YES;
    }
    else
    {
        [self.btnLeft setImage:[UIImage imageNamed:@"common_btn_menu"] forState:UIControlStateNormal];
        self.btnRight.hidden = NO;
    }
    
    self.cvImages.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    self.cvImages.center = CGPointMake(self.viewImages.frame.size.width / 2, self.viewImages.frame.size.height / 2);
}

- (IBAction)onMenu:(id)sender
{
    if(self.isOwner)
    {
        [super onMenu:sender];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onPopmenu:(id)sender
{
    if(self.isOwner)
    {
        if(self.editProfileView == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"EditProfileView"] owner:nil options:nil];
            EditProfileView *editProfileView = [nib objectAtIndex:0];
            editProfileView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewMainDetail.frame.origin.y);
            editProfileView.delegate = self;
            
            [self.view addSubview:editProfileView];
            self.editProfileView = editProfileView;
        }
        
        [self.view bringSubviewToFront:self.editProfileView];
        
        [self startEditingProfile];
    }
    else
    {
        self.btnEditProfile.selected = !self.btnEditProfile.isSelected;
        
        if(self.btnEditProfile.isSelected)
        {
            [self.btnEditProfile setTitle:@"+Subscribe" forState:UIControlStateNormal];
            [self.btnEditProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.btnEditProfile setBackgroundColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f]];
        }
        else
        {
            [self.btnEditProfile setTitle:@"Unsubscribe" forState:UIControlStateNormal];
            [self.btnEditProfile setTitleColor:[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.btnEditProfile setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

- (void) startEditingProfile
{
    self.btnEditProfileImage.hidden = NO;
    
    [self.editProfileView showMenu];
    self.viewBlur.hidden = NO;
}

- (void) stopEditingProfile
{
    self.btnEditProfileImage.hidden = YES;
    
    self.viewBlur.hidden = YES;
}

- (IBAction)onEditProfileImage:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing", @"Take a Photo", nil];
    
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void) openLibrary
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void) openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfCategoriesToShow = 0;
    for (int i = 0; i < 3; i++) {
        if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
            numberOfCategoriesToShow++;
        }
    }
    if (numberOfCategoriesToShow > 0) {
        numberOfCategoriesToShow++;
    }
    return numberOfCategoriesToShow;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(PostCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexOfCategories = 0;
    NSInteger countOfCategories = 0;
    if (indexPath.item == 0) {
        for (int i = 0; i < 3; i++) {
            if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
                break;
            }
            indexOfCategories++;
        }
    } else {
        for (int i = 0; i < 3; i++) {
            if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
                countOfCategories++;
                if (countOfCategories == indexPath.item) {
                    break;
                }
            }
            indexOfCategories++;
        }
    }
    
    PFObject *imageObjectToShow = categoryObjects[indexOfCategories];
    [cell.ivPost setImageWithURL:[NSURL URLWithString:[(PFFile *)(imageObjectToShow[@"mainImage"]) url]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (indexPath.item != 0) {
        indexOfCategories++;
    } else {
        indexOfCategories = 0;
    }
    if (indexOfCategories== 0)
    {
        //[cell.ivPost setImageWithURL:[NSURL URLWithString:[(PFFile *)(imageObjectToShow[@"mainImage"]) url]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //cell.ivPost.image = [UIImage imageNamed:@"rate_image"];
        cell.lblDescription.hidden = NO;
        cell.ivIcon.hidden = YES;
    }
    else if(indexOfCategories == 1)
    {
        //cell.ivPost.image = [UIImage imageNamed:@"profile_image"];
        cell.lblDescription.hidden = YES;
        cell.ivIcon.hidden = NO;
        cell.ivIcon.image = [UIImage imageNamed:@"common_icon_nightlife_white"];
    }
    else if(indexOfCategories == 2)
    {
        //cell.ivPost.image = [UIImage imageNamed:@"flyweek_image"];
        cell.lblDescription.hidden = YES;
        cell.ivIcon.hidden = NO;
        cell.ivIcon.image = [UIImage imageNamed:@"common_icon_professional_white"];
    }
    else if(indexOfCategories == 3)
    {
        //cell.ivPost.image = [UIImage imageNamed:@"rate_image"];
        cell.lblDescription.hidden = YES;
        cell.ivIcon.hidden = NO;
        cell.ivIcon.image = [UIImage imageNamed:@"common_icon_streetwear_white"];
    }
    
    cell.viewMain.frame = CGRectMake(0, 0, (self.cvImages.frame.size.width - 10) / 2, (self.cvImages.frame.size.width - 10) / 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.cvImages.frame.size.width - 10) / 2, (self.cvImages.frame.size.width - 10) / 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexOfCategories = 0;
    NSInteger countOfCategories = 0;
    if (indexPath.item == 0) {
        for (int i = 0; i < 3; i++) {
            if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
                break;
            }
            indexOfCategories++;
        }
    } else {
        for (int i = 0; i < 3; i++) {
            if ([categoryObjects[i] isKindOfClass:[PFObject class]]) {
                countOfCategories++;
                if (countOfCategories == indexPath.item) {
                    break;
                }
            }
            indexOfCategories++;
        }
    }
    
    if (indexPath.item != 0) {
        indexOfCategories++;
    } else {
        indexOfCategories = 0;
    }
    
    if (self.isOwner) {
        [self performSegueWithIdentifier:@"ProfileExpanded" sender:@{@"occasionIndex": [NSNumber numberWithInteger:indexOfCategories], @"isOwner": [NSNumber numberWithBool:self.isOwner], @"userProfileObject": [PFUser currentUser]}];
    } else {
        [self performSegueWithIdentifier:@"ProfileExpanded" sender:@{@"occasionIndex": [NSNumber numberWithInteger:indexOfCategories], @"isOwner": [NSNumber numberWithBool:self.isOwner], @"userProfileObject": self.pfoUser}];
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark EditProfileViewDelegate

- (void) doneEditProfile:(NSString *)username
{
    [self stopEditingProfile];
}

- (void) logout
{
    NSLog(@"Logged out of facebook");
    
    if ([PFUser currentUser]) {
        [PFUser logOut];
    }
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    if (loginManager && [FBSDKAccessToken currentAccessToken]) {
        [loginManager logOut];
    }
    
    if ([PFUser currentUser]) {
        [PFUser logOut];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:NO forKey:@"LoggedIn"];
    [prefs synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)
    {
        if(buttonIndex == 0)
        {
            [self openLibrary];
        }
        else if(buttonIndex == 1)
        {
            [self openCamera];
        }
    }
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    self.ivProfile.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
