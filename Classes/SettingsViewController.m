//
//  SettingsViewController.m
//  iRoseTime
//
//  Created by Curtis Clifton on 11/25/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import "SettingsViewController.h"
#import "iRoseTimeAppDelegate.h"

static NSInteger const _SYNC_IMAGE_WIDTH = 1400;
static NSInteger const _BLUR_IMAGE_WIDTH = 200;
static NSInteger const _POINTS_PER_SECOND = 5;

@interface SettingsViewController (/* Private */)
- (void)_setSyncTimeBar;
@end

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated;
{
    [self _setSyncTimeBar];
}

#pragma mark -
#pragma mark Custom Logic

@synthesize syncTimeBar;

- (IBAction)synchronizeToBellNow;
{
    iRoseTimeAppDelegate *appDelegate = (iRoseTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.roseTime synchronizeToBell]) {
        [self _setSyncTimeBar];
    } else {
        // CONSIDER: add option to sync to a specified bell, in which case we make a new RoseTime instance and force a new bell offset
        UIAlertView *noSyncAlert = [[UIAlertView alloc] initWithTitle:@"Unable to synchronize with bells now" message:@"Sorry, but the device time isn’t close enough to an expected bell time to automatically synchronize." delegate:nil cancelButtonTitle:@"OK, I’ll try later" otherButtonTitles:nil];
        [noSyncAlert show];
        [noSyncAlert release];
    }
}

#pragma mark - Private API

- (void)_setSyncTimeBar;
{
    iRoseTimeAppDelegate *appDelegate = (iRoseTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSTimeInterval bellOffset = appDelegate.roseTime.bellOffset;
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    NSInteger baseXPosition = (screenWidth/2) - _BLUR_IMAGE_WIDTH -(_SYNC_IMAGE_WIDTH/2);
    NSInteger xPosition = baseXPosition - rint(bellOffset)*_POINTS_PER_SECOND;
    CGRect frame = self.syncTimeBar.frame;
    frame.origin.x = xPosition;
    self.syncTimeBar.frame = frame;
}

@end
