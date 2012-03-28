//
//  SettingsViewController.h
//  iRoseTime
//
//  Created by Curtis Clifton on 11/25/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import <UIKit/UIKit.h>
#import "RoseTime.h"

@interface SettingsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *syncTimeBar;

- (IBAction)synchronizeToBellNow;

@end
