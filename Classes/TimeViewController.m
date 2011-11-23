//
//  FirstViewController.m
//  iRoseTime
//
//  Created by Curtis Clifton on 11/24/10.
//  Copyright 2010 Computer Science and Software Engineering, Rose-Hulman Institute of Technology. All rights reserved.
//

#import "TimeViewController.h"
#import "iRoseTimeAppDelegate.h"


#define VISIBLE_TIME_BAR_BEGIN (7.0*60*60)
#define TIME_BAR_BEGINS_OPAQUE (7.5*60*60)
#define TIME_BAR_ENDS_OPAQUE ((12 + 5.5)*60*60)
#define VISIBLE_TIME_BAR_END ((12 + 6.0)*60*60)

#define TIME_BAR_MIN_Y 66.5
#define TIME_BAR_VERTICAL_TRAVEL 303.0

@implementation TimeViewController

@synthesize currentTimeLabel;
@synthesize countDownLabel;
@synthesize timeBarView;
@synthesize reticuleView;

#pragma mark -
#pragma mark Custom View Logic

- (void) updateTimeDisplay:(NSTimer*)theTimer {
    [UIView beginAnimations:@"Update Time" context:nil];
    [UIView setAnimationDuration:0.5];
    
    iRoseTimeAppDelegate *appDelegate = (iRoseTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentTimeLabel.text = [appDelegate.roseTime currentTimeAsString];
    
    NSInteger secondsToBell = [appDelegate.roseTime secondsUntilNextBell];
    if (secondsToBell > 60 * 60) {
        self.countDownLabel.alpha = 0.0f;
    } else {
        self.countDownLabel.alpha = 1.0f;
    }
    NSInteger minutes = secondsToBell / 60;
    NSInteger seconds = secondsToBell - minutes * 60;
    NSString *newText = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    self.countDownLabel.text = newText;
    
    NSInteger secondsPastMidnight = [appDelegate.roseTime secondsPastMidnightAtRose];
    if (secondsPastMidnight < VISIBLE_TIME_BAR_BEGIN) {
        self.reticuleView.alpha = 0.0;
        CGPoint ctr = self.timeBarView.center;
        ctr.y = TIME_BAR_MIN_Y;
        self.timeBarView.center = ctr;		
    } else if (secondsPastMidnight > VISIBLE_TIME_BAR_END) {
        self.reticuleView.alpha = 0.0;
        CGPoint ctr = self.timeBarView.center;
        ctr.y = TIME_BAR_MIN_Y + TIME_BAR_VERTICAL_TRAVEL;
        self.timeBarView.center = ctr;		
    } else {
        CGFloat travelRatio = (secondsPastMidnight - VISIBLE_TIME_BAR_BEGIN) / (VISIBLE_TIME_BAR_END - VISIBLE_TIME_BAR_BEGIN);
        CGPoint ctr = self.timeBarView.center;
        ctr.y = TIME_BAR_MIN_Y + TIME_BAR_VERTICAL_TRAVEL * travelRatio;
        NSLog(@"Setting y location of time bar to %.2f", ctr.y);
        self.timeBarView.center = ctr;
        CGFloat fadeRatio;
        if (secondsPastMidnight < TIME_BAR_BEGINS_OPAQUE) {
            fadeRatio = (secondsPastMidnight - VISIBLE_TIME_BAR_BEGIN) / (TIME_BAR_BEGINS_OPAQUE - VISIBLE_TIME_BAR_BEGIN);
        } else if (secondsPastMidnight > TIME_BAR_ENDS_OPAQUE) {
            fadeRatio = (secondsPastMidnight - TIME_BAR_ENDS_OPAQUE) / (VISIBLE_TIME_BAR_END - TIME_BAR_ENDS_OPAQUE);
            fadeRatio = 1.0 - fadeRatio;
        } else {
            fadeRatio = 1.0;
        }
        self.reticuleView.alpha = fadeRatio;
    }
    
    
    // Break the number of seconds down into ranges.
    // 0-7*60*60, alpha = 0.0
    // 7-8*60*60, fade in and move
    // 8-5:10, alpha = 1.0 and move
    // 5:10-6pm, fade out and move
    // 6- alpha = 0.0
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Overrides


/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTimeDisplay:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 
                                     target:self 
                                   selector:@selector(updateTimeDisplay:)
                                   userInfo:nil
                                    repeats:YES];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.currentTimeLabel = nil;
    self.timeBarView = nil;
    
    // CONSIDER: do you need to invalidate the timer?
}


- (void)dealloc {
    [currentTimeLabel release];
    [timeBarView release];
    
    [super dealloc];
}

@end
