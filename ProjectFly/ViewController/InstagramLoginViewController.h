//
//  InstagramLoginViewController.h
//  Fly
//
//  Created by Alvin Keti on 23/04/15.
//
//

#import <UIKit/UIKit.h>
#import <InstagramKit/InstagramKit.h>

typedef NS_OPTIONS(NSInteger, IKLoginScope) {
    //    Default, to read any and all data related to a user (e.g. following/followed-by lists, photos, etc.)
    IKLoginScopeBasic = 0,
    //    to create or delete comments on a user’s behalf
    IKLoginScopeComments = 1<<1,
    //    to follow and unfollow users on a user’s behalf
    IKLoginScopeRelationships = 1<<2,
    //    to like and unlike items on a user’s behalf
    IKLoginScopeLikes = 1<<3
};

@interface InstagramLoginViewController : UIViewController

@end