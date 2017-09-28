//
//  TagViewController.m
//  ProjectFly
//
//  Created by han on 2/21/15.
//
//

#import "TagViewController.h"
#import "TagView.h"
#import "EditImageViewController.h"

@interface TagViewController () <TagViewDelegate>
{
    TagView *_editingTagView;
    NSMutableArray *arrayOfTagViews;
}

@property (weak, nonatomic) IBOutlet UIView *viewImage;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (weak, nonatomic) IBOutlet UIView *viewEditTagText;

@property (weak, nonatomic) IBOutlet UITextField *txtBrand;
@property (weak, nonatomic) IBOutlet UITextField *txtDes;

@end

@implementation TagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _editingTagView = nil;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.viewImage addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    self.viewEditTagText.frame = CGRectMake(0, 0, self.view.frame.size.width, - self.viewEditTagText.frame.size.height);
    
    arrayOfTagViews = [NSMutableArray new];
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

- (BOOL)prefersStatusBarHidden {
    return self.viewEditTagText.frame.origin.y == 0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.viewImage.frame = CGRectMake(0, self.viewImage.frame.origin.y, self.view.frame.size.width, self.view.frame.size.width);
    float pos = self.viewImage.frame.origin.y + self.viewImage.frame.size.height;
    self.viewBottom.frame = CGRectMake(0, pos, self.view.frame.size.width, self.view.frame.size.height - pos);
    
    if(self.image != nil)
    {
        self.ivImage.image = self.image;
    }
    
    for (NSDictionary *tag in self.arrayOfTags) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"TagView"] owner:nil options:nil];
        TagView *tagView = [nib objectAtIndex:0];
        tagView.delegate = self;
        
        tagView.brand = tag[@"brand"];
        tagView.item = tag[@"item"];
        [tagView done:[NSString stringWithFormat:@"%@ %@", tag[@"brand"], tag[@"item"]]];
        tagView.center = CGPointMake([tag[@"positionX"] floatValue], [tag[@"positionY"] floatValue]);
        tagView.isMove = YES;
        
        [self.viewImage addSubview:tagView];
        [arrayOfTagViews addObject:tagView];
    }
}

- (IBAction)onBack:(id)sender
{
    EditImageViewController *vc = (EditImageViewController *)(self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2]);
    NSMutableArray *arrayOfTags = [NSMutableArray new];
    for (TagView *tagView in arrayOfTagViews) {
        NSDictionary *tag = @{@"brand":tagView.brand, @"item":tagView.item, @"positionX":[NSNumber numberWithFloat:tagView.center.x], @"positionY":[NSNumber numberWithFloat:tagView.center.y]};
        [arrayOfTags addObject:tag];
    }
    vc.arrayOfTags = arrayOfTags;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDoneEditTag:(id)sender
{
    [self.txtBrand resignFirstResponder];
    [self.txtDes resignFirstResponder];
    
    NSString *tagText = [NSString stringWithFormat:@"%@ %@", self.txtBrand.text, self.txtDes.text];
    
    _editingTagView.brand = self.txtBrand.text;
    _editingTagView.item = self.txtDes.text;
    [_editingTagView done:tagText];
    _editingTagView = nil;
    
    [self hideEditTagView];
}

- (void) tapImage:(UIGestureRecognizer *)gesture
{
    if(_editingTagView != nil) return;
    
    CGPoint touchLocation = [gesture locationInView:self.viewImage];
    
    [self addTagEditView:touchLocation];
    
    [self showEditTagView];
}

- (void) showEditTagView
{
    self.viewInfo.hidden = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
       
        self.viewEditTagText.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewEditTagText.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        [self setNeedsStatusBarAppearanceUpdate];
       
    }];
}

- (BOOL) isShowedEditTagView
{
    return self.viewEditTagText.frame.origin.x == 0;
}

- (void) hideEditTagView
{
    self.viewInfo.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewEditTagText.frame = CGRectMake(0, 0, self.view.frame.size.width, - self.viewEditTagText.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        self.txtBrand.text = @"";
        self.txtDes.text = @"";
        
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void) addTagEditView:(CGPoint )point
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[DataManager getXibName:@"TagView"] owner:nil options:nil];
    TagView *tagView = [nib objectAtIndex:0];
    tagView.delegate = self;
    tagView.isMove = YES;
    
    tagView.center = CGPointMake(point.x, point.y + tagView.frame.size.height / 2);
    
    [self.viewImage addSubview:tagView];
    [arrayOfTagViews addObject:tagView];
    
    [tagView startEdit];
    
    _editingTagView = tagView;
    
    [_editingTagView initState];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark TagViewDelegate

- (void) closeTag:(UIView *)view
{
    if(_editingTagView == view)
    {
        [self hideEditTagView];
    }
    [arrayOfTagViews removeObject:view];
}

@end
