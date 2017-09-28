//
//  EditImageViewController.m
//  Fly
//
//  Created by han on 3/6/15.
//
//

#import "EditImageViewController.h"
#import "ViewImageViewController.h"
#import "TagViewController.h"
#import "TagView.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface EditImageViewController ()
{
    BOOL _isAddingImageToMap;
    MBProgressHUD *hudUploading;
    MBProgressHUD *hudSaving;
}

@property (weak, nonatomic) IBOutlet UIView *viewDescription;

@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblDescriptionPlaceholder;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIButton *btnAddToPhotoMap;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToPhotoMap1;

@end

@implementation EditImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewDescription.layer.borderColor = [UIColor colorWithRed:170.0f / 255.0f green:170.0f / 255.0f blue:170.0f / 255.0f alpha:1.0f].CGColor;
    self.viewDescription.layer.borderWidth = 1.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
    [self.ivImage addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    hudUploading = [[MBProgressHUD alloc] initWithView:self.view];
    hudUploading.labelText = @"Uploading";
    hudUploading.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudUploading];
    
    hudSaving = [[MBProgressHUD alloc] initWithView:self.view];
    hudSaving.labelText = @"Saving";
    hudSaving.color = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.9f];
    //hudUploading.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hudSaving];
    
    if ([self.method isEqualToString:@"edit"]) {
        self.arrayOfTags = self.imageObject[@"tags"];
        self.txtDescription.text = self.imageObject[@"caption"];
        self.lblDescriptionPlaceholder.hidden = self.txtDescription.text.length > 0;
    } else {
        self.arrayOfTags = [NSArray new];
    }
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
    
    if([segue.identifier isEqualToString:@"EditTag"])
    {
        TagViewController *vc = segue.destinationViewController;
        vc.image = [sender objectForKey:@"image"];
        vc.arrayOfTags = [sender objectForKey:@"arrayOfTags"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if(self.image != nil)
    {
        self.ivImage.image = self.image;
        [self.btnSave setTitle:@"Submit" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnSave setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    [self updateUI];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) willShowKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self repositionMainView:keyboardFrameBeginRect.size.height];
}

- (void) willChangeKeyboardFrame:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self repositionMainView:keyboardFrameBeginRect.size.height];
}

- (void) willHideKeyboard:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.btnSave.center = CGPointMake(self.btnSave.center.x, self.view.frame.size.height - self.btnSave.frame.size.height / 2);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) repositionMainView:(float) keyboardHeight
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.btnSave.center = CGPointMake(self.btnSave.center.x, self.view.frame.size.height - keyboardHeight - self.btnSave.frame.size.height / 2);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) tapView
{
    [self.txtDescription resignFirstResponder];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender
{
    // Confirm user not using photo map
    /*if(!_isAddingImageToMap)
    {
        [self showAlertView:nil message:@"Are you sure you do not want to set a location? Adding a location makes your photo easier to discover!" cancel:@"Go Back" ok:@"Continue" tag:0];
        
        return ;
    }*/
    
    if(self.image == nil)
        [self onBack:nil];
    else if([self.method isEqualToString:@"upload"])
    {
        PFUser *parseCurrentUser = [PFUser currentUser];
        NSLog(@"%f, %f", self.image.size.width, self.image.size.height);
        
        NSData *imageData = UIImageJPEGRepresentation([EditImageViewController imageWithImage:self.image scaledToSize:CGSizeMake(640.0f, 640.f)], 1.0f);
        PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
        
        PFObject *uploadImage = [PFObject objectWithClassName:@"Image"];
        uploadImage[@"mainImage"] = imageFile;
        uploadImage[@"caption"] = self.txtDescription.text;
        uploadImage[@"fashionCategory"] = self.category;
        uploadImage[@"fiveStarsReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"fourStarsReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"threeStarsReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"twoStarsReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"oneStarReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"isDeleted"] = [NSNumber numberWithBool:NO];
        uploadImage[@"isFlagged"] = [NSNumber numberWithBool:NO];
        uploadImage[@"ratedCount"] = [NSNumber numberWithInt:0];
        uploadImage[@"currentRating"] = [NSNumber numberWithInt:0];
        uploadImage[@"totalStarsReceived"] = [NSNumber numberWithInt:0];
        uploadImage[@"isApproved"] = [NSNumber numberWithBool:YES];
        uploadImage[@"tags"] = self.arrayOfTags;
        uploadImage[@"uploader"] = parseCurrentUser;
        
        [hudUploading show:YES];
        
        //[uploadImage saveInBackground];
        [uploadImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                
                [hudUploading hide:YES];
                
                //[self flyOfWeekWithMenu:nil];
                
                [self gotoViewImageScreen:uploadImage];
            } else {
                // There was a problem, check error.description
                
                NSLog(@"%@", error);
            }
        }];
        
        PFObject *parseCurrentUserMetaData = parseCurrentUser[@"metaData"];
        
        [parseCurrentUserMetaData incrementKey:@"uploadCount"];
        [parseCurrentUserMetaData saveInBackground];
    } else {
        self.imageObject[@"caption"] = self.txtDescription.text;
        self.imageObject[@"tags"] = self.arrayOfTags;
        
        [hudSaving show:YES];
        
        [self.imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                
                [hudSaving hide:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                // There was a problem, check error.description
                
                NSLog(@"%@", error);
            }
        }];
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) gotoViewImageScreen:(PFObject *)imageObject
{
    ViewImageViewController *viewImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewImageViewController"];
    viewImageVC.isFromUpload = YES;
    viewImageVC.imageObject = imageObject;
    
    [self.navigationController pushViewController:viewImageVC animated:YES];
}

- (IBAction)onTag:(id)sender
{
    [self performSegueWithIdentifier:@"EditTag" sender:@{@"image": self.image, @"arrayOfTags": self.arrayOfTags}];
}

- (IBAction)onAddPhotoToMap:(id)sender
{
    if(self.image == nil) return;
    
    _isAddingImageToMap = !_isAddingImageToMap;
    
    [self updateUI];
}

- (IBAction)onFacebook:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (IBAction)onFlickr:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (IBAction)onInstagram:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (IBAction)onPinterest:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (IBAction)onTumblr:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (IBAction)onTiwtter:(id)sender
{
    [self showAlertView:nil message:@"The Fly team is working on this feature-check back soon!" cancel:@"Okay" ok:nil tag:0];
}

- (void) tapImage
{
    [self showLightBox:self.ivImage.image];
}

- (void) updateUI
{
    if(!_isAddingImageToMap)
    {
        [self.btnAddToPhotoMap setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnAddToPhotoMap1.selected = YES;
    }
    else
    {
        [self.btnAddToPhotoMap setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.btnAddToPhotoMap1.selected = NO;
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.lblDescriptionPlaceholder.hidden = YES;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.lblDescriptionPlaceholder.hidden = textView.text.length > 0;
    
    return YES;
}

#pragma mark AlertViewDelegate

- (void) onOkWithAlertView:(UIView *)alertView
{
    //[self gotoViewImageScreen];
}

- (void) onCancelWithAlertView:(UIView *)alertView
{
    
}

@end
