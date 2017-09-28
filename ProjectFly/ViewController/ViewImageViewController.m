//
//  ViewImageViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "ViewImageViewController.h"
#import "DataManager.h"
#import "TagView.h"
#import "EditImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewImageViewController () <TagViewDelegate>
{
    BOOL _isShowingTag;
    NSString *locationOfUploader;
    MBProgressHUD *hudDeleting;
    MBProgressHUD *hudLoading;
    
    PFObject *_favoriteObject;
    BOOL isFavorite;
    
    BOOL _isNotLoadNew;
}

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIView *viewImage;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;

@property (weak, nonatomic) IBOutlet UIView *viewTag;

@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIImageView *ivOccasionIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivGenderIcon;

@property (weak, nonatomic) IBOutlet UIImageView *ivUploader;
@property (weak, nonatomic) IBOutlet UILabel *lblUploaderUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadDate;
@property (weak, nonatomic) IBOutlet UILabel *lblViewCount;
@property (weak, nonatomic) IBOutlet UILabel *lblFiveStarRatingCount;
@property (weak, nonatomic) IBOutlet UILabel *lblFourStarRatingCount;

@end

@implementation ViewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationIndex = 1;
    self.occasionIndex = 1;
    self.genderIndex = 1;
    
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImage)];
    likeTap.numberOfTapsRequired = 2;
    
    [self.viewImage addGestureRecognizer:likeTap];
    
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage)];
    openTap.numberOfTapsRequired = 1;
    
    [self.viewImage addGestureRecognizer:openTap];
    
    [openTap requireGestureRecognizerToFail:likeTap];
    
    self.ivUploader.layer.cornerRadius = self.ivUploader.frame.size.width / 2;
    self.ivUploader.clipsToBounds = YES;
    
    locationOfUploader = @"";
    
    hudDeleting = [[MBProgressHUD alloc] initWithView:self.view];
    hudDeleting.labelText = @"Deleting";
    hudDeleting.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudDeleting];
    
    hudLoading = [[MBProgressHUD alloc] initWithView:self.view];
    hudLoading.labelText = @"Loading";
    hudLoading.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudLoading];
    
    _isNotLoadNew = NO;
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
    
    if([segue.identifier isEqualToString:@"EditImage"])
    {
        EditImageViewController *vc = segue.destinationViewController;
        vc.image = [sender objectForKey:@"image"];
        vc.category = [sender objectForKey:@"category"];
        vc.method = [sender objectForKey:@"method"];
        vc.imageObject = [sender objectForKey:@"imageObject"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.isFromUpload)
    {
        [self.btnLeft setImage:[UIImage imageNamed:@"common_btn_menu"] forState:UIControlStateNormal];
        isFavorite = NO;
    }
    else
    {
        [self.btnLeft setImage:[UIImage imageNamed:@"common_btn_back"] forState:UIControlStateNormal];
        
        if (!_isNotLoadNew) {
            PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
            [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
            [favoriteQuery whereKey:@"image" equalTo:self.imageObject];
            [favoriteQuery whereKey:@"isFavorite" equalTo:[NSNumber numberWithBool:YES]];
            [hudLoading show:YES];
            [favoriteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if (objects.count > 0) {
                        _favoriteObject = objects[0];
                        isFavorite = YES;
                    }
                }
                [hudLoading hide:YES];
            }];
        } else {
            _isNotLoadNew = NO;
        }
    }
    
    if (self.imageObject) {
        [self.ivImage setImageWithURL:[NSURL URLWithString:[(PFFile *)(self.imageObject[@"mainImage"]) url]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self updateUI];
}

- (IBAction)onBack:(id)sender
{
    if(self.isFromUpload)
       [self onMenu:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTag:(id)sender
{
    _isShowingTag = !_isShowingTag;
    
    [self updateUI];
}

- (IBAction)onSubmenu:(id)sender
{
    CGPoint pos = [self.viewInfo convertPoint:CGPointMake(0, 0) toView:self.view];

    if ([[self.imageObject[@"uploader"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Edit Photo", @"Delete Photo", nil];
        [self showActionsheet:pos.y title:nil cancel:@"Cancel" buttons:aryButtons red:1 tag:0];
    } else {
        if(!isFavorite)
        {
            NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Flag Image", @"Favorite Photo", nil];
            [self showActionsheet:pos.y title:nil cancel:@"Cancel" buttons:aryButtons red:0 tag:2];
        }
        else
        {
            NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Flag Image", @"Unfavorite Photo", nil];
            [self showActionsheet:pos.y title:nil cancel:@"Cancel" buttons:aryButtons red:0 tag:3];
        }
    }
}

- (void) updateUI
{
    self.viewTag.hidden = !_isShowingTag;
    
    //[self updateFilterIcons];
    
    if (self.imageObject) {
        PFUser *uploader = self.imageObject[@"uploader"];
        /*if ([uploader.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
            uploader = [PFUser currentUser];
        } else {
            [uploader fetch];
        }*/
        
        self.lblTitle.text = [NSString stringWithFormat:@"Viewing %@'s photo", [uploader objectForKey:@"appUsername"]];
        
        NSString *avatarField = [DataManager is6PlusScreen] ? @"profileAvatarLarge" : @"profileAvatarMedium";
        [self.ivUploader setImageWithURL:[NSURL URLWithString:[(PFFile *)(uploader[avatarField]) url]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.lblUploaderUsername.text = uploader[@"appUsername"];
        self.lblDesc.text = self.imageObject[@"caption"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        self.lblUploadDate.text = [NSString stringWithFormat:@"Uploaded %@", [dateFormatter stringFromDate:self.imageObject.createdAt]];
        self.lblViewCount.text = @"1.1 Million Views";
        self.lblFiveStarRatingCount.text = [NSString stringWithFormat:@"%d", [self.imageObject[@"fiveStarsReceived"] intValue]];
        self.lblFourStarRatingCount.text = [NSString stringWithFormat:@"%d", [self.imageObject[@"fourStarsReceived"] intValue]];
        self.lblViewCount.text = [NSString stringWithFormat:@"%d Views", [self.imageObject[@"ratedCount"] intValue]];
        
        if ([uploader[@"gender"] isEqualToString:@"male"]) {
            self.genderIndex = 2;
        } else if ([uploader[@"gender"] isEqualToString:@"female"]) {
            self.genderIndex = 1;
        } else {
            self.genderIndex = 0;
        }
        
        if ([self.imageObject[@"fashionCategory"] isEqualToString:@"Nightlife"]) {
            self.occasionIndex = 1;
        } else if ([self.imageObject[@"fashionCategory"] isEqualToString:@"Professional"]) {
            self.occasionIndex = 2;
        } else if ([self.imageObject[@"fashionCategory"] isEqualToString:@"Streetwear"]) {
            self.occasionIndex = 3;
        } else {
            self.occasionIndex = 0;
        }
        
        locationOfUploader = uploader[@"userLocation"];
        locationOfUploader = [locationOfUploader componentsSeparatedByString:@","][0];
        self.locationIndex = 1;
        
        [self updateFilterIcons];
        
        for (UIView *subview in self.viewTag.subviews) {
            if ([subview isKindOfClass:[TagView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        for (NSDictionary *tag in self.imageObject[@"tags"]) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"TagView"] owner:nil options:nil];
            TagView *tagView = [nib objectAtIndex:0];
            tagView.delegate = self;
            
            tagView.brand = tag[@"brand"];
            tagView.item = tag[@"item"];
            [tagView done:[NSString stringWithFormat:@"%@ %@", tag[@"brand"], tag[@"item"]]];
            tagView.center = CGPointMake([tag[@"positionX"] floatValue], [tag[@"positionY"] floatValue]);
            tagView.btnClose.hidden = YES;
            tagView.isMove = NO;
            
            [self.viewTag addSubview:tagView];
        }
    }
}

- (void) updateFilterIcons
{
    float pos = self.ivGenderIcon.center.x;
    
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
    
    if(!self.ivGenderIcon.isHidden) pos -= [DataManager is6PlusScreen] ? 26 : 25;
    
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
    
    if(!self.ivOccasionIcon.isHidden)
    {
        self.ivOccasionIcon.center = CGPointMake (pos, self.ivOccasionIcon.center.y);
        //pos -= [DataManager is6PlusScreen] ? 54 : 40;
    }
    else
    {
        pos -= [DataManager is6PlusScreen] ? 32 : 20;
    }
    
    if ([locationOfUploader isEqualToString:@""]) {
        self.locationIndex = 0;
    }
    self.lblLocation.hidden = NO;
    if(self.locationIndex == 0)
    {
        self.lblLocation.hidden = YES;
    }
    else
    {
        //self.lblLocation.text = locations[self.locationIndex];
        self.lblLocation.text = locationOfUploader;
        [self.lblLocation sizeToFit];
        self.lblLocation.frame = CGRectMake(0, 0, self.lblLocation.frame.size.width + 10, [DataManager is6PlusScreen] ? 20 :10);
        pos -= (self.lblLocation.frame.size.width + 10) / 2 + 16;
    }
    
    self.lblLocation.center = CGPointMake (pos, self.ivOccasionIcon.center.y);
}

- (void) likeImage
{
    if (![[self.imageObject[@"uploader"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIImage *image = [UIImage imageNamed:@"rate_icon_heart"];
        NSInteger imageWidth = CGImageGetWidth([image CGImage]);
        __block float aspectRatio = (float)self.viewImage.frame.size.width / (float)imageWidth;
        __block UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        BOOL hasMarked = YES;
        if (hasMarked)
            imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        else
            imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
        
        [self.viewImage addSubview:imageView];
        [self.viewImage bringSubviewToFront:imageView];
        imageView.center = CGPointMake(self.viewImage.frame.size.width / 2, self.viewImage.frame.size.height / 2);
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (hasMarked)
                imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
            else
                imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                imageView.alpha = 0.0f;
            } completion:^(BOOL finished){
                [imageView removeFromSuperview];
                imageView = nil;
            }];
        }];
        
        [self favoriteCurrentImage];
    }
}

- (void) favoriteCurrentImage {
    if (!isFavorite) {
        PFObject *favoriteObject = [PFObject objectWithClassName:@"Favorite"];
        favoriteObject[@"user"] = [PFUser currentUser];
        favoriteObject[@"image"] = self.imageObject;
        favoriteObject[@"imageObjectId"] = [self.imageObject objectId];
        favoriteObject[@"isFavorite"] = [NSNumber numberWithBool:YES];
        favoriteObject[@"fashionCategory"] = self.imageObject[@"fashionCategory"];
        favoriteObject[@"gender"] = self.imageObject[@"uploader"][@"gender"];
        favoriteObject[@"userLocation"] = self.imageObject[@"uploader"][@"userLocation"];
        [favoriteObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                _favoriteObject = favoriteObject;
                isFavorite = YES;
            } else {
                // There was a problem, check error.description
                
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void) unfavoriteCurrentImage
{
    if (!isFavorite) {
        [_favoriteObject deleteInBackground];
        isFavorite = NO;
    }
}

- (void) flagCurrentImage {
    self.imageObject[@"isFlagged"] = [NSNumber numberWithBool:YES];
    [self.imageObject saveInBackground];
}

- (void) openImage
{
    [self showLightBox:self.ivImage.image];
    _isNotLoadNew = YES;
}

#pragma mark ActionSheetDelegate

- (void) onButtonClickWithActionsheet:(UIView *)actionSheetView index:(int)index
{
    if(actionSheetView.tag == 0)
    {
        if(index == 0)
        {
            [self performSegueWithIdentifier:@"EditImage" sender:@{@"image": self.ivImage.image, @"category": self.imageObject[@"fashionCategory"], @"method": @"edit", @"imageObject": self.imageObject}];
        }
        else if(index == 1)
        {
            CGPoint pos = [self.viewInfo convertPoint:CGPointMake(0, 0) toView:self.view];
            
            NSArray *aryButtons = [[NSArray alloc] initWithObjects:@"Confirm", nil];
            [self showActionsheet:pos.y title:@"Delete this photo?" cancel:@"Cancel" buttons:aryButtons red:0 tag:1];
        }
    }
    else if(actionSheetView.tag == 1)
    {
        if(index == 0)
        {
            PFUser *currentUser = [PFUser currentUser];
            
            self.imageObject[@"isDeleted"] = [NSNumber numberWithBool:YES];
            [hudDeleting show:YES];
            [self.imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [hudDeleting hide:YES];
                if (succeeded) {
                    // The object has been saved.
                    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
                    [favoriteQuery whereKey:@"image" equalTo:self.imageObject];
                    [favoriteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error) {
                            NSLog(@"%@", error);
                        } else {
                            for (PFObject *favoriteObject in objects) {
                                [favoriteObject deleteInBackground];
                            }
                        }
                    }];
                    [currentUser[@"metaData"] incrementKey:@"uploadCount" byAmount:[NSNumber numberWithInt:-1]];
                    [currentUser[@"metaData"] saveInBackground];
                    
                    [self onBack:nil];
                } else {
                    // There was a problem, check error.description
                    NSLog(@"%@", error);
                }
            }];
        }
    } else if(actionSheetView.tag == 2)
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
    else if(actionSheetView.tag == 3)
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
