//
//  LightBoxViewController.m
//  Fly
//
//  Created by han on 3/7/15.
//
//

#import "LightBoxViewController.h"

@interface LightBoxViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet UIScrollView *svMain;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;

@end

@implementation LightBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
    [self.svMain addGestureRecognizer:tapGesture];
    tapGesture = nil;
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
    
    if(self.image != nil)
    {
        self.ivImage.image = self.image;
    }
}

- (IBAction)onDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) tapImage
{
    self.btnDone.hidden = NO;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    self.btnDone.hidden = YES;
    
    return self.ivImage;
}

@end
