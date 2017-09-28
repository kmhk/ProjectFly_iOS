//
//  RateViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "RateViewController.h"
#import "ProfileViewController.h"
#import "ImageView.h"
#import "RatingView.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface RateViewController ()<UIActionSheetDelegate, RatingViewDelegate, ImageViewDelegate>
{
    int _numberOfPost;
    
    int _currentIndex;
    
    int _backStep;
    
    BOOL _rated;
    
    MBProgressHUD *hudLoading;
    MBProgressHUD *hudProcessing;
    
    BOOL _isLoadOnScroll;
}

@property (nonatomic, assign) int locationIndex;
@property (nonatomic, assign) int occasionIndex;
@property (nonatomic, assign) int genderIndex;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;

@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (weak, nonatomic) IBOutlet UILabel *lblPrev;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UILabel *lblNext;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivOutOfImages;

@property (weak, nonatomic) IBOutlet UIScrollView *svImages;
@property (weak, nonatomic) IBOutlet UIScrollView *svRateViews;

@property (nonatomic, strong) NSMutableArray *aryImageViews;
@property (nonatomic, strong) NSMutableArray *aryRatingViews;
@property (nonatomic, strong) NSMutableArray *arySees;

@property (nonatomic, strong) NSMutableArray *aryFavorites;
@property (nonatomic, strong) NSMutableArray *aryFlags;
@property (nonatomic, strong) NSMutableArray *aryRatedImageIndices;

@property (nonatomic, strong) NSMutableArray *aryPosts;
@property (nonatomic, strong) NSMutableDictionary *dicFavoritesForPosts;
@property (nonatomic, strong) NSArray *aryLoadingImageObjects;
@property (nonatomic, strong) NSArray *aryLoadingFavoriteObjects;

@end

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationIndex = 0;
    self.occasionIndex = 0;
    self.genderIndex = 0;
    
    hudProcessing = [[MBProgressHUD alloc] initWithView:self.view];
    hudProcessing.labelText = @"Processing";
    hudProcessing.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudProcessing];
    
    hudLoading = [[MBProgressHUD alloc] initWithView:self.view];
    hudLoading.labelText = @"Loading";
    hudLoading.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudLoading];
    
    [self loadMoreImages];
    
    self.svImages.contentSize = CGSizeMake(self.svImages.frame.size.width * _numberOfPost, self.svImages.frame.size.height);
    self.svRateViews.contentSize = CGSizeMake(self.svRateViews.frame.size.width * _numberOfPost, self.svRateViews.frame.size.height);
    
    [self updateUI];
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
    
    [self updateUI];
}

- (void)loadMoreImages {
    _numberOfPost = 0;
    _currentIndex = 0;
    
    _backStep = 0;
    
    _rated = NO;
    
    if (self.aryImageViews) {
        for (ImageView *imageView in self.aryImageViews) {
            [imageView removeFromSuperview];
            //[self.aryImageViews removeObject:imageView];
        }
    }
    
    if (self.aryRatingViews) {
        for (RatingView *ratingView in self.aryRatingViews) {
            [ratingView removeFromSuperview];
            //[self.aryRatingViews removeObject:ratingView];
        }
    }
    
    self.aryPosts = [NSMutableArray new];
    self.aryImageViews = [[NSMutableArray alloc] init];
    self.aryRatingViews = [[NSMutableArray alloc] init];
    self.aryFavorites = [[NSMutableArray alloc] init];
    self.aryFlags = [NSMutableArray new];
    self.aryRatedImageIndices = [NSMutableArray new];
    self.arySees = [NSMutableArray new];
    
    [hudLoading show:YES];
    
    self.aryLoadingImageObjects = nil;
    self.aryLoadingFavoriteObjects = nil;
    
    PFQuery *seeUserQuery = [PFQuery queryWithClassName:@"See"];
    [seeUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" notEqualTo:[PFUser currentUser][@"username"]];
    if (self.genderIndex > 0) {
        [userQuery whereKey:@"gender" equalTo:[genders[self.genderIndex] lowercaseString]];
    }
    if (self.locationIndex > 0) {
        [userQuery whereKey:@"userLocation" hasPrefix:locations[self.locationIndex]];
    }
    PFQuery *imageQuery = [PFQuery queryWithClassName:@"Image"];
    [imageQuery whereKey:@"isDeleted" equalTo:[NSNumber numberWithBool:NO]];
    [imageQuery whereKey:@"isApproved" equalTo:[NSNumber numberWithBool:YES]];
    [imageQuery whereKey:@"objectId" doesNotMatchKey:@"imageObjectId" inQuery:seeUserQuery];
    [imageQuery whereKey:@"uploader" matchesQuery:userQuery];
    if (self.occasionIndex > 0) {
        [imageQuery whereKey:@"fashionCategory" equalTo:occasions[self.occasionIndex]];
    }
    
    [imageQuery includeKey:@"uploader"];
    [imageQuery includeKey:@"uploader.metaData"];
    //imageQuery.limit = 10;
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.aryLoadingImageObjects = objects;
            
            [self processLoadedImages:self.aryLoadingImageObjects WithFavorites:self.aryLoadingFavoriteObjects];
        }
    }];
    
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
    [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [favoriteQuery whereKey:@"imageObjectId" matchesKey:@"objectId" inQuery:imageQuery];
    [favoriteQuery whereKey:@"isFavorite" equalTo:[NSNumber numberWithBool:YES]];
    [favoriteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.aryLoadingFavoriteObjects = objects;
            
            [self processLoadedImages:self.aryLoadingImageObjects WithFavorites:self.aryLoadingFavoriteObjects];
        }
    }];
}

- (void)processLoadedImages:(NSArray *)aryImageObjects WithFavorites:(NSArray *)aryFavoriteObjects
{
    if (!aryImageObjects || !aryFavoriteObjects) {
        return;
    }
    
    self.aryPosts = [NSMutableArray new];
    self.dicFavoritesForPosts = [NSMutableDictionary new];
    
    _numberOfPost = (int)aryImageObjects.count;
    if (_numberOfPost > 10) {
        _numberOfPost = 10;
    }
    NSMutableArray *aryRandomIndex = [NSMutableArray new];
    for (int n = 0 ; n < _numberOfPost ; n ++) {
        BOOL isAddRandomNumber = NO;
        while (!isAddRandomNumber) {
            int randomNumber = arc4random() % (int)aryImageObjects.count;
            if (![aryRandomIndex containsObject:[NSNumber numberWithInt:randomNumber]]) {
                [aryRandomIndex addObject:[NSNumber numberWithInt:randomNumber]];
                isAddRandomNumber = YES;
            }
        }
    }
    
    _currentIndex = 0;
    
    _backStep = 0;
    
    _rated = NO;
    
    self.aryImageViews = [[NSMutableArray alloc] init];
    self.aryFavorites = [[NSMutableArray alloc] init];
    self.aryFlags = [NSMutableArray new];
    self.aryRatedImageIndices = [NSMutableArray new];
    self.arySees = [NSMutableArray new];
    
    if (_numberOfPost <= 0) {
        self.svImages.hidden = YES;
        self.svRateViews.hidden = YES;
        self.ivOutOfImages.hidden = NO;
    } else {
        self.svImages.hidden = NO;
        self.svRateViews.hidden = NO;
        self.ivOutOfImages.hidden = YES;
    }
    
    for (int n = 0 ; n < _numberOfPost ; n++) {
        PFObject *imageObject = aryImageObjects[[aryRandomIndex[n] intValue]];
        [self.aryPosts addObject:imageObject];
        
        NSString *xibName = @"ImageView";
        if([DataManager is6PlusScreen]) xibName = @"ImageView_6plus";
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil];
        ImageView *imageView = [nib objectAtIndex:0];
        imageView.delegate = self;
        imageView.frame = CGRectMake(self.svImages.frame.size.width * n , 0, self.svImages.frame.size.width, self.svImages.frame.size.height);
        
        PFFile *imageFile = [imageObject objectForKey:@"mainImage"];
        [imageView.ivImage setImageWithURL:[NSURL URLWithString:imageFile.url] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        PFUser *uploader = [imageObject objectForKey:@"uploader"];
        imageView.lblUsername.text = uploader[@"appUsername"];
        NSString *imagePath = [(PFFile *)(uploader[@"profileAvatarLarge"]) url];
        [imageView.ivUserAvatar setImageWithURL:[NSURL URLWithString:imagePath] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageView.ivUserAvatar.layer.cornerRadius = imageView.ivUserAvatar.frame.size.width / 2;
        imageView.ivUserAvatar.clipsToBounds = YES;
        imageView.lblCaption.text = [imageObject objectForKey:@"caption"];
        imageView.pfoUploader = uploader;
        
        if ([uploader[@"gender"] isEqualToString:@"male"]) {
            imageView.genderIndex = 2;
        } else if ([uploader[@"gender"] isEqualToString:@"female"]) {
            imageView.genderIndex = 1;
        } else {
            imageView.genderIndex = 0;
        }
        
        if ([imageObject[@"fashionCategory"] isEqualToString:@"Nightlife"]) {
            imageView.occasionIndex = 1;
        } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Professional"]) {
            imageView.occasionIndex = 2;
        } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Streetwear"]) {
            imageView.occasionIndex = 3;
        } else {
            imageView.occasionIndex = 0;
        }
        
        imageView.locationOfImage = [uploader[@"userLocation"] componentsSeparatedByString:@","][0];
        imageView.locationIndex = 1;
        
        [imageView _update];
        
        [self.svImages addSubview:imageView];
        [self.aryImageViews addObject:imageView];
        
        ////////////////////////////////
        
        UIImage *selectedStarImage = [UIImage imageNamed:@"common_image_star_act"];
        UIImage *unselectedStarImage = [UIImage imageNamed:@"common_image_star"];
        
        RatingView *ratingView = [[RatingView alloc] initWith:selectedStarImage image:unselectedStarImage size:CGSizeMake(34, 34) interval:40];
        ratingView.delegate = self;
        
        NSLog(@"%d", ratingView.rate);
        
        ratingView.center = CGPointMake(self.svRateViews.frame.size.width * n + self.svRateViews.frame.size.width * 0.5, self.svRateViews.frame.size.height * 0.5);
        [self.svRateViews addSubview:ratingView];
        [self.aryRatingViews addObject:ratingView];
        
        NSArray *aryFavoritesForImageObject = [aryFavoriteObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(imageObjectId == %@)", [imageObject objectId]]];
        
        if (aryFavoritesForImageObject.count > 0) {
            [self.dicFavoritesForPosts setObject:aryFavoritesForImageObject[0] forKey:[imageObject objectId]];
            
            if(![self.aryFavorites containsObject:[NSNumber numberWithInt:n]])
            {
                [self.aryFavorites addObject:[NSNumber numberWithInt:n]];
            }
        }
    }
    
    if (_numberOfPost > 0) {
        self.svImages.contentSize = CGSizeMake(self.svImages.frame.size.width * _numberOfPost, self.svImages.frame.size.height);
        self.svRateViews.contentSize = CGSizeMake(self.svRateViews.frame.size.width * _numberOfPost, self.svRateViews.frame.size.height);
        
        [self.svImages setContentOffset:CGPointMake(_currentIndex * self.svImages.frame.size.width, 0) animated:NO];
    }
    
    _currentIndex = 0;
    
    [self updateUI];
    [hudLoading hide:YES];
    
    _isLoadOnScroll = NO;
}

- (IBAction)onPrev:(id)sender
{
    if (_numberOfPost <= 0) {
        return;
    }
    if(_backStep == -1) return;
    
    _backStep = _backStep - 1;
    _currentIndex = MAX(_currentIndex - 1, 0);
    
    _rated = ((UIImageView *)[self.aryImageViews objectAtIndex:_currentIndex]).tag > 0;
    
    [self.svImages setContentOffset:CGPointMake(self.svImages.frame.size.width * _currentIndex, 0) animated:YES];
    
    [self updateUI];
}

- (IBAction)onNext:(id)sender
{
    if (_numberOfPost <= 0) {
        [self loadMoreImages];
    } else {
        if(_rated == NO) return;
        
        if (_currentIndex == _numberOfPost - 1) {
            [self rateImage:_currentIndex WithLoadMore:YES];
        } else {
            _backStep = 0;
            _currentIndex = MIN(_currentIndex + 1, _numberOfPost - 1);
            
            _rated = ((UIImageView *)[self.aryImageViews objectAtIndex:_currentIndex]).tag > 0;
            
            [self.svImages setContentOffset:CGPointMake(self.svImages.frame.size.width * _currentIndex, 0) animated:YES];
            
            [self updateUI];
        }
    }
}

- (void)rateImage:(int)currentImageIndex WithLoadMore:(BOOL)isLoadMore {
//    NSLog(@"-- Starting Rate image --");
    for (int i = 0; i < _numberOfPost; i++) {
        NSLog(@"%d", [self.aryRatingViews[i] rate]);
    }
    
    BOOL isAddNew;
    if(![self.aryRatedImageIndices containsObject:[NSNumber numberWithInt:currentImageIndex]])
    {
        isAddNew = YES;
    } else {
        isAddNew = NO;
    }
    
    PFObject *imageObject = self.aryPosts[currentImageIndex];
    NSInteger rate = [self getCurrentImageRate];
    
    PFUser *currentUser = [PFUser currentUser];
    PFObject *see = [PFObject objectWithClassName:@"See"];
    
    PFQuery *seeQuery = [PFQuery queryWithClassName:@"See"];
    NSInteger previousRating = 0;
    
    if (!isAddNew) {
        see = self.arySees[currentImageIndex];
        if (!see.objectId) {
            [seeQuery whereKey:@"user" equalTo:currentUser];
            [seeQuery whereKey:@"image" equalTo:imageObject];
            
            [hudProcessing show:YES];
            
            [seeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                self.arySees[currentImageIndex] = object;
                [self rateImage:currentImageIndex WithLoadMore:NO];
                [hudProcessing hide:YES];
            }];
            return;
        }
        
        previousRating = [see[@"rating"] integerValue];
    } else {
        see[@"user"] = currentUser;
        see[@"image"] = imageObject;
        see[@"imageObjectId"] = imageObject.objectId;
    }
    
    see[@"rating"] = [NSNumber numberWithInteger:rate];
    if([self.aryFavorites containsObject:[NSNumber numberWithInt:currentImageIndex]])
    {
        see[@"isFavorite"] = [NSNumber numberWithBool:YES];
    } else {
        see[@"isFavorite"] = [NSNumber numberWithBool:NO];
    }
    if([self.aryFlags containsObject:[NSNumber numberWithInt:currentImageIndex]])
    {
        see[@"isFlag"] = [NSNumber numberWithBool:YES];
    } else {
        see[@"isFlag"] = [NSNumber numberWithBool:NO];
    }
    int currentIndexForSavingSee = currentImageIndex;
    [see saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            
            if (isLoadMore) {
                [self loadMoreImages];
            } else {
                self.arySees[currentIndexForSavingSee] = see;
            }
        } else {
            // There was a problem, check error.description
            NSLog(@"%@", error);
        }
    }];
    
    if (currentImageIndex < self.arySees.count) {
        self.arySees[currentImageIndex] = see;
    } else {
        [self.arySees addObject:see];
    }
    
    NSString *ratingFieldForUploader;
    NSString *ratingFieldForUser;
    NSString *ratingFieldForPreviousUploader;
    NSString *ratingFieldForPreviousUser;
    switch (rate) {
        case 1:
            ratingFieldForUploader = @"oneStarReceived";
            ratingFieldForUser = @"oneStarGiven";
            break;
            
        case 2:
            ratingFieldForUploader = @"twoStarsReceived";
            ratingFieldForUser = @"twoStarsGiven";
            break;
            
        case 3:
            ratingFieldForUploader = @"threeStarsReceived";
            ratingFieldForUser = @"threeStarsGiven";
            break;
            
        case 4:
            ratingFieldForUploader = @"fourStarsReceived";
            ratingFieldForUser = @"fourStarsGiven";
            break;
            
        case 5:
            ratingFieldForUploader = @"fiveStarsReceived";
            ratingFieldForUser = @"fiveStarsGiven";
            break;
            
        default:
            ratingFieldForUploader = @"fiveStarsReceived";
            ratingFieldForUser = @"fiveStarsGiven";
            break;
    }
    if (!isAddNew) {
        switch (previousRating) {
            case 1:
                ratingFieldForPreviousUploader = @"oneStarReceived";
                ratingFieldForPreviousUser = @"oneStarGiven";
                break;
                
            case 2:
                ratingFieldForPreviousUploader = @"twoStarsReceived";
                ratingFieldForPreviousUser = @"twoStarsGiven";
                break;
                
            case 3:
                ratingFieldForPreviousUploader = @"threeStarsReceived";
                ratingFieldForPreviousUser = @"threeStarsGiven";
                break;
                
            case 4:
                ratingFieldForPreviousUploader = @"fourStarsReceived";
                ratingFieldForPreviousUser = @"fourStarsGiven";
                break;
                
            case 5:
                ratingFieldForPreviousUploader = @"fiveStarsReceived";
                ratingFieldForPreviousUser = @"fiveStarsGiven";
                break;
                
            default:
                ratingFieldForPreviousUploader = @"fiveStarsReceived";
                ratingFieldForPreviousUser = @"fiveStarsGiven";
                break;
        }
    }
    
    if (!isAddNew) {
        [imageObject incrementKey:ratingFieldForPreviousUploader byAmount:[NSNumber numberWithInt:-1]];
    }
    [imageObject incrementKey:ratingFieldForUploader];
    
    if (isAddNew) {
        [imageObject incrementKey:@"ratedCount"];
    }
    
    float rating = 0;
    rating = 5 * [imageObject[@"fiveStarsReceived"] intValue] + 4 * [imageObject[@"fourStarsReceived"] intValue] + 3 * [imageObject[@"threeStarsReceived"] intValue] + 2 * [imageObject[@"twoStarsReceived"] intValue] + 1 * [imageObject[@"oneStarReceived"] intValue];
    rating /= [imageObject[@"ratedCount"] intValue];
    imageObject[@"currentRating"] = [NSNumber numberWithFloat:rating];
    [imageObject saveInBackground];
    
    PFUser *uploader = imageObject[@"uploader"];
    if (!isAddNew) {
        [uploader[@"metaData"] incrementKey:ratingFieldForPreviousUploader byAmount:[NSNumber numberWithInt:-1]];
    }
    [uploader[@"metaData"] incrementKey:ratingFieldForUploader];
    NSString *categoryPrefix;
    if ([imageObject[@"fashionCategory"] isEqualToString:@"Nightlife"]) {
        categoryPrefix = @"night";
    } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Professional"]) {
        categoryPrefix = @"prof";
    } else if ([imageObject[@"fashionCategory"] isEqualToString:@"Streetwear"]) {
        categoryPrefix = @"street";
    }
    if (isAddNew) {
        NSString *categoryRatingFieldForUploader = [NSString stringWithFormat:@"%@ReceivedRatingCount", categoryPrefix];
        [uploader[@"metaData"] incrementKey:categoryRatingFieldForUploader];
    }
    [uploader[@"metaData"] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
//            NSLog(@"success metadata");
        } else {
            // There was a problem, check error.description
            NSLog(@"%@", error);
        }
    }];
    
    if (!isAddNew) {
        [currentUser[@"metaData"] incrementKey:ratingFieldForPreviousUser byAmount:[NSNumber numberWithInt:-1]];
    }
    [currentUser[@"metaData"] incrementKey:ratingFieldForUser];
    if (isAddNew) {
        NSString *categoryRatingFieldForUser = [NSString stringWithFormat:@"%@RatedCount", categoryPrefix];
        [currentUser[@"metaData"] incrementKey:categoryRatingFieldForUser];
    }
    [currentUser[@"metaData"] saveInBackground];
    
    self.aryPosts[currentImageIndex] = imageObject;
    
    if(![self.aryRatedImageIndices containsObject:[NSNumber numberWithInt:currentImageIndex]])
    {
        [self.aryRatedImageIndices addObject:[NSNumber numberWithInt:currentImageIndex]];
    }
    
    /*if (isLoadMore) {
        [self loadMoreImages];
    }*/
//    NSLog(@"-- Ending Rate image --");
}

- (void)favoriteImage:(BOOL)isFavorite WithCurrentImageIndex:(int)currentImageIndex {
    BOOL isAddNew;
    
    PFUser *currentUser = [PFUser currentUser];
    PFObject *favoriteObject = [PFObject objectWithClassName:@"Favorite"];
    
    if (!self.dicFavoritesForPosts[[self.aryPosts[currentImageIndex] objectId]]) {
        isAddNew = YES;
        
        favoriteObject[@"user"] = currentUser;
        favoriteObject[@"image"] = self.aryPosts[currentImageIndex];
        favoriteObject[@"imageObjectId"] = [self.aryPosts[currentImageIndex] objectId];
        favoriteObject[@"fashionCategory"] = self.aryPosts[currentImageIndex][@"fashionCategory"];
        favoriteObject[@"gender"] = self.aryPosts[currentImageIndex][@"uploader"][@"gender"];
        favoriteObject[@"userLocation"] = self.aryPosts[currentImageIndex][@"uploader"][@"userLocation"];
    } else {
        isAddNew = NO;
        
        favoriteObject = self.dicFavoritesForPosts[[self.aryPosts[currentImageIndex] objectId]];
        
        if (!favoriteObject.objectId) {
            PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
            [favoriteQuery whereKey:@"user" equalTo:currentUser];
            [favoriteQuery whereKey:@"image" equalTo:self.aryPosts[currentImageIndex]];
            
            [hudProcessing show:YES];
            [favoriteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self.dicFavoritesForPosts setObject:object forKey:[self.aryPosts[currentImageIndex] objectId]];
                [self favoriteImage:isFavorite WithCurrentImageIndex:currentImageIndex];
                [hudProcessing hide:YES];
            }];
            return;
        }
    }
    
    if (isFavorite) {
        favoriteObject[@"isFavorite"] = [NSNumber numberWithBool:isFavorite];
        [favoriteObject saveInBackground];
    } else {
        [favoriteObject deleteInBackground];
    }
    
    [self.dicFavoritesForPosts setObject:favoriteObject forKey:[self.aryPosts[currentImageIndex] objectId]];
    if (!isFavorite) {
        [self.dicFavoritesForPosts removeObjectForKey:[self.aryPosts[currentImageIndex] objectId]];
    }
}

- (int) getCurrentImageRate
{
    if(_currentIndex >= self.aryImageViews.count) return 0;
    
    UIImageView *currentImageView = [self.aryImageViews objectAtIndex:_currentIndex];
    
    return (int)currentImageView.tag;
}

- (IBAction)onSubmenu:(id)sender
{
    float pos = self.viewContent.frame.origin.y + self.viewContent.frame.size.height - ([DataManager is6PlusScreen] ? 120 : 92);//[self.viewInfo convertPoint:CGPointMake(0, 0) toView:self.view];
    
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

- (void) updateUI
{
    if(_numberOfPost == 0)
    {
        self.lblNext.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnNext.alpha = 0.6f;
        
        self.lblPrev.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnPrev.alpha = 0.6f;
    }
    else if(_currentIndex <= 0)
    {
        self.lblPrev.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnPrev.alpha = 0.6f;
        
        self.lblNext.textColor = [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
        self.btnNext.alpha = 1.0f;
    }
    else if(_currentIndex >= _numberOfPost - 1)
    {
        self.lblPrev.textColor = [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
        self.btnPrev.alpha = 1.0f;
        
        self.lblNext.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnNext.alpha = 0.6f;
    }
    else
    {
        self.lblNext.textColor = [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
        self.btnNext.alpha = 1.0f;
        
        self.lblPrev.textColor = [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
        self.btnPrev.alpha = 1.0f;
    }
    
    if(_backStep < 0)
    {
        self.lblPrev.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnPrev.alpha = 0.6f;
    }
    
    if(_rated == NO && self.btnNext.alpha == 1.0f)
    {
        self.lblNext.textColor = [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.btnNext.alpha = 0.6f;
    }
    
    ////////////////////////////////////////
    
    /*
    for (int n = 0 ; n < self.aryImageViews.count; n ++) {
        ImageView *imageView = [self.aryImageViews objectAtIndex:n];
        
        imageView.locationIndex = self.locationIndex;
        imageView.occasionIndex = self.occasionIndex;
        imageView.genderIndex = self.genderIndex;
        
        [imageView _update];
    }*/

}

- (void) gotoProfileScreen:(PFUser *)profileObject
{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.isOwner = NO;
    vc.pfoUser = profileObject;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) isFavoritedImage
{
    return [self.aryFavorites containsObject:[NSNumber numberWithInt:_currentIndex]];
}

- (void) favoriteCurrentImage
{
    if(![self.aryFavorites containsObject:[NSNumber numberWithInt:_currentIndex]])
    {
        [self.aryFavorites addObject:[NSNumber numberWithInt:_currentIndex]];
        [self favoriteImage:YES WithCurrentImageIndex:_currentIndex];
    }
}

- (void) unfavoriteCurrentImage
{
    if([self.aryFavorites containsObject:[NSNumber numberWithInt:_currentIndex]])
    {
        [self.aryFavorites removeObject:[NSNumber numberWithInt:_currentIndex]];
        [self favoriteImage:NO WithCurrentImageIndex:_currentIndex];
    }
}

- (BOOL) isFlaggedImage
{
    return [self.aryFlags containsObject:[NSNumber numberWithInt:_currentIndex]];
}

- (void) flagCurrentImage
{
    if(![self.aryFlags containsObject:[NSNumber numberWithInt:_currentIndex]])
    {
        [self.aryFlags addObject:[NSNumber numberWithInt:_currentIndex]];
        PFObject *imageObject = [self.aryPosts objectAtIndex:_currentIndex];
        imageObject[@"isFlagged"] = [NSNumber numberWithBool:YES];
        [imageObject saveInBackground];
    }
}

- (void) unflagCurrentImage
{
    if([self.aryFlags containsObject:[NSNumber numberWithInt:_currentIndex]])
    {
        [self.aryFlags removeObject:[NSNumber numberWithInt:_currentIndex]];
        PFObject *imageObject = [self.aryPosts objectAtIndex:_currentIndex];
        imageObject[@"isFlagged"] = [NSNumber numberWithBool:NO];
        [imageObject saveInBackground];
    }
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.svImages)
    {
        if(_backStep < 0  && scrollView.contentOffset.x < _currentIndex * scrollView.frame.size.width)
        {
            [scrollView setContentOffset:CGPointMake(_currentIndex * scrollView.frame.size.width, 0)];
        }
        else if(!_rated && scrollView.contentOffset.x > _currentIndex * scrollView.frame.size.width)
        {
            [scrollView setContentOffset:CGPointMake(_currentIndex * scrollView.frame.size.width, 0)];
        }
        else
        {
            float pagePos = scrollView.contentOffset.x - (float)(_numberOfPost - 1) * self.svImages.frame.size.width;
            CGRect rtScreen = [[UIScreen mainScreen] bounds];
            if (!_isLoadOnScroll && pagePos > (float)rtScreen.size.width * 0.2) {
                _isLoadOnScroll = YES;
                [self rateImage:_currentIndex WithLoadMore:YES];
            } else {
                int pageIndex = (scrollView.contentOffset.x + scrollView.frame.size.width / 2) / self.svImages.frame.size.width;
                [self checkPageChange:pageIndex];
            }
        }
        
        self.svRateViews.contentOffset = CGPointMake(self.svImages.contentOffset.x, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pageIndex = (scrollView.contentOffset.x + scrollView.frame.size.width / 2) / self.svImages.frame.size.width;
    
    [self checkPageChange:pageIndex];
    
    [scrollView setContentOffset:CGPointMake(_currentIndex * scrollView.frame.size.width, 0) animated:YES];
}

- (void) checkPageChange:(int)newPageIndex
{
    if(newPageIndex != _currentIndex)
    {
        if (_rated) {
            [self rateImage:_currentIndex WithLoadMore:NO];
        }
        
        if(newPageIndex > _currentIndex && _rated)
        {
            _backStep = 0;
            _currentIndex = MIN(_currentIndex + 1, _numberOfPost - 1);
            
            _rated = ((UIImageView *)[self.aryImageViews objectAtIndex:_currentIndex]).tag > 0;
            
            [self updateUI];
        }
        else
        {
            _backStep = _backStep - 1;
            _currentIndex = MAX(_currentIndex - 1, 0);
            
            _rated = ((UIImageView *)[self.aryImageViews objectAtIndex:_currentIndex]).tag > 0;
            
            [self updateUI];
        }
    }
}

#pragma mark RatingViewDelegate

- (void) updatedRate:(float)rate
{
    if(_currentIndex >= self.aryImageViews.count) return;
    
    UIImageView *currentImageView = [self.aryImageViews objectAtIndex:_currentIndex];
    currentImageView.tag = (int)rate;
    
    _rated = YES;
    
    [self updateUI];
}

#pragma mark FilterViewDelegate

- (void) applyFilterOption
{
    self.occasionIndex = self.filterView.occasionIndex;
    self.locationIndex = self.filterView.locationIndex;
    self.genderIndex = self.filterView.genderIndex;
    
    [self loadMoreImages];
    
    [self updateUI];
}

#pragma mark ImageViewDelegate

- (void) profileWithUploader:(PFUser *)uploader
{
    [self gotoProfileScreen:uploader];
}

- (void) flagWithImage:(NSDictionary *)image
{
    [self onSubmenu:nil];
}

- (void) likeWithImage:(UIImage *)image
{
    [self favoriteCurrentImage];
}

- (void) openImageWithImage:(UIImage *)image
{
    [self showLightBox:image];
}

@end
