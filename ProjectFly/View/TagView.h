//
//  TagView.h
//  ProjectFly
//
//  Created by hanjinghe on 1/9/15.
//  Copyright (c) 2015 bentonow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  TagViewDelegate <NSObject>

- (void) closeTag:(UIView *)view;

@end

@interface TagView : UIView

@property (nonatomic, assign) id <TagViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblTagName;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *item;
//@property (nonatomic) CGSize boundarySize;
@property (nonatomic) BOOL isMove;

- (void) initState;

- (void) startEdit;
- (void) done:(NSString *)tagName;

@end
