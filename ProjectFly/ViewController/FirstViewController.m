//
//  FirstViewController.m
//  ProjectFly
//
//  Created by han on 2/20/15.
//
//

#import "FirstViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Facebook-iOS-SDK/FBSDKCoreKit/FBSDKCoreKit.h>
#import <Facebook-iOS-SDK/FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface FirstViewController ()
{
    MBProgressHUD *hudProcessing;
}
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    hudProcessing = [[MBProgressHUD alloc] initWithView:self.view];
    hudProcessing.labelText = @"Processing";
    hudProcessing.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudProcessing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"Profile"])
    {
        ProfileViewController *vc = segue.destinationViewController;
        vc.isOwner = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    BOOL isLoggedIn = [prefs boolForKey:@"LoggedIn"];
    
    if(isLoggedIn)
    {
        [self gotoRateScreen];
    }
}

- (IBAction)onSigninWithFacebook:(id)sender
{
    if ([PFUser currentUser]) {
        [self gotoProfileScreen];
        return;
    }
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken]; // Use existing access token.
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [[NSNotificationCenter defaultCenter] addObserver:[[UIApplication sharedApplication] delegate] selector:@selector(profileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
    
    if (accessToken) {
        // Log In (create/update currentUser) with FBSDKAccessToken
        [PFFacebookUtils logInInBackgroundWithAccessToken:accessToken block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. There was an error logging in.");
            } else {
                NSLog(@"User logged in through Facebook!");
                [self gotoProfileScreen];
            }
        }];
    } else {
        [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_birthday", @"user_location"] block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                
                //[[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email"}]
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSLog(@"fetched user:%@", result);
                         PFUser *currentParseUser = [PFUser currentUser];
                         currentParseUser[@"email"] = result[@"email"];
                         currentParseUser[@"facebookUserObjectId"] = result[@"id"];
                         currentParseUser[@"appUsername"] = [NSString stringWithFormat:@"%@ %@.", result[@"first_name" ], [result[@"last_name"] substringToIndex:1]];
                         currentParseUser[@"name"] = result[@"name"];
                         currentParseUser[@"firstName"] = result[@"first_name"];
                         currentParseUser[@"lastName"] = result[@"last_name"];
                         
                         NSDate *currentUserBirthdate = [[NSDate alloc] init];
                         NSString *birthdateString = result[@"birthday"];
                         if (birthdateString) {
                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                             [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                             [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                             currentUserBirthdate = [dateFormatter dateFromString:result[@"birthday"]];
                         } else {
                             currentUserBirthdate = [NSDate date];
                         }
                         
                         NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                            components:NSCalendarUnitYear
                                                            fromDate:currentUserBirthdate
                                                            toDate:[NSDate date]
                                                            options:0];
                         NSInteger currentUserAge = [ageComponents year];
                         
                         currentParseUser[@"birthday"] = currentUserBirthdate;
                         currentParseUser[@"age"] = [NSNumber numberWithInteger:currentUserAge];
                         currentParseUser[@"gender"] = result[@"gender"];
                         currentParseUser[@"facebookLink"] = result[@"link"];
                         if (result[@"location"][@"name"]) {
                             currentParseUser[@"userLocation"] = result[@"location"][@"name"];
                             
                             /*PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
                             [locationQuery whereKey:@"name" equalTo:result[@"location"][@"name"]];
                             [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                 if (error) {
                                     NSLog(@"%@", error);
                                 } else {
                                     if (objects.count > 0) {
                                         PFObject *location = [PFObject objectWithClassName:@"Location"];
                                         location[@"name"] = result[@"location"][@"name"];
                                         [location saveInBackground];
                                     }
                                 }
                             }];*/
                         } else {
                             currentParseUser[@"userLocation"] = @"";
                         }
                         
                         PFObject *userMetadata = [PFObject objectWithClassName:@"UserMetaData"];
                         userMetadata[@"followerCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"followingCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"uploadCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"fiveStarsGiven"] = [NSNumber numberWithInt:0];
                         userMetadata[@"fourStarsGiven"] = [NSNumber numberWithInt:0];
                         userMetadata[@"threeStarsGiven"] = [NSNumber numberWithInt:0];
                         userMetadata[@"twoStarsGiven"] = [NSNumber numberWithInt:0];
                         userMetadata[@"oneStarGiven"] = [NSNumber numberWithInt:0];
                         userMetadata[@"fiveStarsReceived"] = [NSNumber numberWithInt:0];
                         userMetadata[@"fourStarsReceived"] = [NSNumber numberWithInt:0];
                         userMetadata[@"threeStarsReceived"] = [NSNumber numberWithInt:0];
                         userMetadata[@"twoStarsReceived"] = [NSNumber numberWithInt:0];
                         userMetadata[@"oneStarReceived"] = [NSNumber numberWithInt:0];
                         userMetadata[@"nightRatedCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"profRatedCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"streetRatedCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"nightReceivedRatingCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"profReceivedRatingCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"streetReceivedRatingCount"] = [NSNumber numberWithInt:0];
                         userMetadata[@"user"] = currentParseUser;
                         
                         [hudProcessing show:YES];
                         
                         [userMetadata saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                             if (succeeded) {
                                 // The object has been saved.
                                 currentParseUser[@"metaData"] = userMetadata;
                                 [currentParseUser saveInBackground];
                                 
                                 [hudProcessing hide:YES];
                                 [self gotoProfileScreen];
                             } else {
                                 // There was a problem, check error.description
                                 NSLog(@"%@", error);
                             }
                         }];
                         
                         currentParseUser[@"isActive"] = [NSNumber numberWithBool:YES];
                         [currentParseUser saveInBackground];
                         
                         [PFCloud callFunctionInBackground:@"uploadMyProfileImage" withParameters:@{@"facebookUserId":[[PFUser currentUser] objectForKey:@"facebookUserObjectId"]} block:^(id object, NSError *error) {
                             if (!error) {
                                 NSLog(@"%@", object);
                             }
                             else {
                                 NSLog(@"error : %@", error);
                             }
                         }];
                         
                         
                     }
                 }];
            } else {
                NSLog(@"User logged in through Facebook!");
                [self gotoProfileScreen];
            }
        }];
    }
}

- (void) gotoProfileScreen
{
    PFObject *userMetaData = [PFUser currentUser][@"metaData"];
    
    [hudProcessing show:YES];
    [userMetaData fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error) {
        // do something with your title variable
        [hudProcessing hide:YES];
        [self performSegueWithIdentifier:@"Profile" sender:nil];
    }];
}

- (void) gotoRateScreen
{
    //[hudProcessing show:YES];
    //[[PFUser currentUser][@"metaData"] fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error) {
        // do something with your title variable
        //[hudProcessing hide:YES];
        [self performSegueWithIdentifier:@"Rate" sender:nil];
    //}];
}

@end
