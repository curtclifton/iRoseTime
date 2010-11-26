//
//  FirstViewController.h
//  iRoseTime
//
//  Created by Curtis Clifton on 11/24/10.
//  Copyright 2010 Computer Science and Software Engineering, Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoseTime.h"


@interface TimeViewController : UIViewController {
}

@property (nonatomic, retain) RoseTime *roseTime;

@property (nonatomic, retain) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *countDownLabel;
@property (nonatomic, retain) IBOutlet UIView *timeBarView;
@property (nonatomic, retain) IBOutlet UIView *reticuleView;

- (void) updateTimeDisplay:(NSTimer*)theTimer;

@end
