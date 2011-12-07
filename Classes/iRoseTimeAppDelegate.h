//
//  iRoseTimeAppDelegate.h
//  iRoseTime
//
//  Created by Curtis Clifton on 11/24/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import <UIKit/UIKit.h>

@class RoseTime;

@interface iRoseTimeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, readonly) RoseTime *roseTime;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
