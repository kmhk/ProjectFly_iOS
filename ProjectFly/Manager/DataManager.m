//
//  DataManager.m
//  Bento App
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DataManager.h"
#import <Parse/Parse.h>

NSString *occasions[SIZE_OCCASIONS] = {@"All", @"Nightlife", @"Professional", @"Streetwear"};
NSString *locations[SIZE_LOCATIONS] = {@"All", @"Los Angeles", @"New York", @"San Francisco"};
NSString *genders[SIZE_GENDERS] = {@"All", @"Female", @"Male"};

@interface DataManager ()

@end

@implementation DataManager

static DataManager *_shareDataManager;

+ (DataManager *)shareDataManager
{
    @synchronized(self) {
        
        if (_shareDataManager == nil)
        {
            _shareDataManager = [[DataManager alloc] init];
        }
    }
    
    return _shareDataManager;
}

+ (void)releaseDataManager
{
    if (_shareDataManager != nil)
    {
        _shareDataManager = nil;
    }
}

- (id) init
{
	if ( (self = [super init]) )
	{

	}
    
    /*if (!self.aryLocation) {
        self.aryLocation = [NSMutableArray new];
        [self.aryLocation addObject:@"All"];
    }*/
	
	return self;
}

+ (BOOL) is6PlusScreen
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    return rtScreen.size.width > 320;
}

+ (NSString *) getXibName:(NSString *)name
{
    NSString *xibName = name;
    if([self is6PlusScreen])
    {
        xibName = [NSString stringWithFormat:@"%@_6plus", name];
    }
    
    return xibName;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    //UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 640), view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

/*+ (void) loadLocation {
    DataManager *dataManager = [self shareDataManager];
    PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
    [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            dataManager.aryLocation = [NSMutableArray new];
            [dataManager.aryLocation addObject:@"All"];
            for (PFObject *location in objects) {
                NSString *locationString = [location[@"name"] componentsSeparatedByString:@","][0];
                if (![dataManager.aryLocation containsObject:locationString] && locationString && ![locationString isEqualToString:@""]) {
                    [dataManager.aryLocation addObject:locationString];
                }
            }
            dataManager.aryLocation = [[dataManager.aryLocation sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        }
    }];
}*/

@end
