//
//  SettingsViewController.h
//  iRoseTime
//
//  Created by Curtis Clifton on 11/25/10.
//  Copyright 2010 Computer Science and Software Engineering, Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoseTime.h"

@interface SettingsViewController : UIViewController {

}

@property (nonatomic, retain) RoseTime *roseTime;

// TODO: synchronization needs to live in a permanently loaded class, the action belongs in the settings tab
- (IBAction) synchronizeToBellNow;

@end
