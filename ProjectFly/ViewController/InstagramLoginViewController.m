//
//  InstagramLoginViewController.m
//  Fly
//
//  Created by Alvin Keti on 23/04/15.
//
//

#import "InstagramLoginViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface InstagramLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *wvInstagramLogin;

@property (nonatomic, assign) IKLoginScope scope;

@end

@implementation InstagramLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wvInstagramLogin.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.wvInstagramLogin.scrollView.bounces = NO;
    self.wvInstagramLogin.contentMode = UIViewContentModeScaleAspectFit;
    self.wvInstagramLogin.delegate = self;
    
    self.scope = IKLoginScopeRelationships | IKLoginScopeComments | IKLoginScopeLikes;
    
    NSDictionary *configuration = [self sharedEngineConfiguration];
    NSString *scopeString = [self stringForScope:self.scope];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    [self.wvInstagramLogin loadRequest:[NSURLRequest requestWithURL:url]];
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

- (NSDictionary*) sharedEngineConfiguration {
    /*NSURL *url = [[NSBundle mainBundle] URLForResource:@"InstagramKit" withExtension:@"plist"];
     NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
     dict = dict ? dict : [[NSBundle mainBundle] infoDictionary];*/
    
    NSDictionary *dict = @{@"InstagramKitAppClientId": @"b35b827b526047229cfab5e66c087b1b",
                           @"InstagramKitAppRedirectURL": @"http://www.project-fly.com",
                           @"InstagramKitBaseUrl": @"https://api.instagram.com/v1/",
                           @"InstagramKitAuthorizationUrl": @"https://api.instagram.com/oauth/authorize/"};
    return dict;
}

- (NSString *)stringForScope:(IKLoginScope)scope
{
    
    NSArray *typeStrings = @[@"basic",@"comments",@"relationships",@"likes"];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:4];
    
#define kBitsUsedByIKLoginScope 4
    
    for (NSUInteger i=0; i < kBitsUsedByIKLoginScope; i++)
    {
        NSUInteger enumBitValueToCheck = 1 << i;
        if (scope & enumBitValueToCheck)
            [strings addObject:[typeStrings objectAtIndex:i]];
    }
    if (!strings.count) {
        return @"basic";
    }
    
    return [strings componentsJoinedByString:@"+"];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    NSString *appRedirectURL = @"http://www.project-fly.com";
    if ([URLString hasPrefix:appRedirectURL]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:accessToken forKey:@"instagram_access_token"];
            [defaults synchronize];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self?access_token=%@", accessToken];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"JSON: %@", responseObject);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:responseObject[@"data"][@"id"] forKey:@"instagram_userid"];
                NSLog(@"User id = %@", responseObject[@"data"][@"id"]);
                [defaults synchronize];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            [self dismissViewControllerAnimated:YES completion:^{
                //[self.collectionViewController reloadMedia];
            }];
        }
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //NSLog(@"Webview failed to load with error: %@", error);
}

- (IBAction)didBackTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

@end
