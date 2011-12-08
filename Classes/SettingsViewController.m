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

@implementation SettingsViewController

#pragma mark -
#pragma mark Custom Logic

- (IBAction)synchronizeToBellNow;
{
    iRoseTimeAppDelegate *appDelegate = (iRoseTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate.roseTime synchronizeToBell]) {
        // CONSIDER: add option to sync to a specified bell, in which case we make a new RoseTime instance and force a new bell offset
        UIAlertView *noSyncAlert = [[UIAlertView alloc] initWithTitle:@"Unable to synchronize with bells now" message:@"Sorry, but the device time isn’t close enough to an expected bell time to automatically synchronize." delegate:nil cancelButtonTitle:@"OK, I’ll try later" otherButtonTitles:nil];
        [noSyncAlert show];
        [noSyncAlert release];
    }
}

@end
