//
//  SettingsViewController.m
//  iRoseTime
//
//  Created by Curtis Clifton on 11/25/10.
//  Copyright 2010 Computer Science and Software Engineering, Rose-Hulman Institute of Technology. All rights reserved.
//

#import "SettingsViewController.h"
#import "iRoseTimeAppDelegate.h"

@implementation SettingsViewController

#pragma mark -
#pragma mark Custom Logic

- (IBAction) synchronizeToBellNow {    
    NSLog(@"got it");
    
    iRoseTimeAppDelegate *appDelegate = (iRoseTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate.roseTime synchronizeToBell]) {
        // CONSIDER: add option to sync to a specified bell, in which case we make a new RoseTime instance and force a new bell offset
        UIAlertView *noSyncAlert = [[UIAlertView alloc] initWithTitle:@"Unable to synchronize with bells now" message:@"Sorry, but the device time isn’t close enough to an expected bell time to automatically synchronize." delegate:nil cancelButtonTitle:@"OK, I’ll try later" otherButtonTitles:nil];
        [noSyncAlert show];
        [noSyncAlert release];
    }
}



#pragma mark -
#pragma mark Overrides

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
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
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
