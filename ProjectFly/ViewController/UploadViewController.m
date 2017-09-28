//
//  UploadViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "UploadViewController.h"
#import "MenuTableViewCell.h"
#import "EditImageViewController.h"
#import "DataManager.h"
#import "DZNPhotoPickerController.h"

#define DROPLIST_HEIGHT  120

#define kInstagramConsumerKey           @"b35b827b526047229cfab5e66c087b1b"
#define kInstagramConsumerSecret        @"80144c5703dc4bc78bf8c802bac08443"

@interface UploadViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNPhotoPickerControllerDelegate>
{
    int _selectedOccasionIndex;
}

@property (weak, nonatomic) IBOutlet UIView *viewCategory;

@property (weak, nonatomic) IBOutlet UIScrollView *svImage;

@property (weak, nonatomic) IBOutlet UILabel *lblCategory;

@property (weak, nonatomic) IBOutlet UIView *viewPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivGrid;

@property (weak, nonatomic) IBOutlet UIView *viewTap;
@property (weak, nonatomic) IBOutlet UITableView *tvPop;

@end

@implementation UploadViewController

+ (void)initialize
{
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceInstagram consumerKey:kInstagramConsumerKey consumerSecret:kInstagramConsumerSecret subscription:DZNPhotoPickerControllerSubscriptionFree];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedOccasionIndex = -1;
    
    UINib *cellNib = [UINib nibWithNibName:@"MenuTableViewCell" bundle:nil];
    [self.tvPop registerNib:cellNib forCellReuseIdentifier:@"MenuCell"];
    
    self.viewCategory.layer.borderWidth = 1;
    self.viewCategory.layer.borderColor = [UIColor colorWithRed:214.0f / 255.0f green:214.0f / 255.0f blue:214.0f / 255.0f alpha:1.0f].CGColor;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage)];
    [self.viewPhoto addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPopDroplistView)];
    [self.viewTap addGestureRecognizer:tapGesture1];
    tapGesture1 = nil;
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
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.viewPhoto.frame = CGRectMake(0, self.viewPhoto.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width);
    
    [self hideDroplist:nil];
    
    [self updateUI];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onUpload:(id)sender
{
    if(_selectedOccasionIndex == -1)
    {
        [self showAlertView:nil message:@"Please select an occasion before proceeding" cancel:@"Okay" ok:nil tag:0];
        
        return;
    }
    else if(self.ivPhoto.image == nil)
    {
        [self showAlertView:nil message:@"Please select an image before proceeding" cancel:@"Okay" ok:nil tag:0];
        
        return;
    }
    
    self.ivGrid.hidden = YES;
    
    UIImage *image = [DataManager imageWithView:self.viewPhoto];
    
    self.ivGrid.hidden = NO;
    
    _selectedOccasionIndex = -1;
    self.ivPhoto.image = nil;
    
    [self performSegueWithIdentifier:@"EditImage" sender:@{@"image": image, @"category": self.lblCategory.text, @"method": @"upload"}];
}

- (IBAction)onProfessional:(id)sender
{
    if([DataManager is6PlusScreen])
        [self showDroplist:CGRectMake(110, 196, self.lblCategory.frame.size.width, DROPLIST_HEIGHT)];
    else
        [self showDroplist:CGRectMake(110, 141, self.lblCategory.frame.size.width, DROPLIST_HEIGHT)];
}

- (void) tapPopDroplistView
{
    [self hideDroplist:nil];
}

- (void) selectImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing", @"Take a Photo", nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"instagram_access_token"] && [defaults objectForKey:@"instagram_userid"]) {
        if ([[defaults objectForKey:@"instagram_access_token"] length] > 1 && [[defaults objectForKey:@"instagram_userid"] length] > 1) {
            [actionSheet addButtonWithTitle:@"Choose from Instagram"];
        }
    }
    
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

- (void) openInstagram {
    DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
    picker.supportedServices = DZNPhotoPickerControllerServiceInstagram;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    picker.initialSearchTerm = @"";
    //picker.initialSearchTerm = [NSString stringWithFormat:@"%@?count=16", [defaults objectForKey:@"instagram_userid"]];
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    picker.enablePhotoDownload = YES;
    picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
    picker.allowAutoCompletedSearch = NO;
    
    picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
        //Your implementation here
        
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) image = info[UIImagePickerControllerOriginalImage];
        
        NSLog(@"%f, %f", image.size.width, image.size.height);
        
        self.ivPhoto.image = image;
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    picker.failureBlock = ^(DZNPhotoPickerController *picker, NSError *error) {
        //Your implementation here
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    };
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void) showDroplist:(CGRect )rect
{
    self.viewTap.hidden = NO;
    self.viewTap.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view bringSubviewToFront:self.viewTap];
    
    self.tvPop.hidden = NO;
    [self.view bringSubviewToFront:self.tvPop];
    
    self.tvPop.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.tvPop.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, DROPLIST_HEIGHT);
    } completion:^(BOOL finished) {
        [self.tvPop reloadData];
    }];
}

- (void) hideDroplist:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3f animations:^{
        self.tvPop.frame = CGRectMake(self.tvPop.frame.origin.x, self.tvPop.frame.origin.y, self.tvPop.frame.size.width, 0);
    } completion:^(BOOL finished) {
        
        self.viewTap.hidden = YES;
        self.tvPop.hidden = YES;
        
        if(completion != nil) completion();
    }];
}

- (BOOL) isShownDroplist
{
    return self.tvPop.frame.size.height > 0;
}

- (void) updateUI
{
    if(_selectedOccasionIndex == -1)
    {
        self.lblCategory.text = @"---";
    }
    else
    {
        self.lblCategory.text = occasions[_selectedOccasionIndex];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)
    {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Existing", nil)]) {
            [self openLibrary];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Take a Photo", nil)]) {
            [self openCamera];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose from Instagram",nil)]) {
            [self openInstagram];
        }
    }
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"%f, %f", image.size.width, image.size.height);
    
    self.ivPhoto.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SIZE_OCCASIONS - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.viewMain.frame = CGRectMake(0, 0, self.tvPop.frame.size.width, 40);
    
    cell.lblText.text = occasions[indexPath.row + 1];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedOccasionIndex = (int)indexPath.row + 1;
    
    [self updateUI];
    
    [self hideDroplist:nil];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.ivPhoto;
}

@end
