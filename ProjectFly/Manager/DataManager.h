//
//  DataManager.h
//  Bento App
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SIZE_OCCASIONS 4
extern NSString *occasions[SIZE_OCCASIONS];

#define SIZE_LOCATIONS 4
extern NSString *locations[SIZE_LOCATIONS];

#define SIZE_GENDERS 3
extern NSString *genders[SIZE_GENDERS];

@interface DataManager : NSObject

//@property (strong, nonatomic) NSMutableArray *aryLocation;

+ (DataManager *)shareDataManager;
+ (void)releaseDataManager;

+ (BOOL) is6PlusScreen;
+ (NSString *) getXibName:(NSString *)name;

+ (UIImage *) imageWithView:(UIView *)view;
+ (void) loadLocation;

@end
