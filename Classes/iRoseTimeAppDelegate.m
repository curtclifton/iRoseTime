//
//  iRoseTimeAppDelegate.m
//  iRoseTime
//
//  Created by Curtis Clifton on 11/24/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import "iRoseTimeAppDelegate.h"
#import "RTTimeSource.h"
#import "RoseTime.h"

@implementation iRoseTimeAppDelegate

@synthesize roseTime;

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    RTActualTimeSource *theTime = [[RTActualTimeSource alloc] init];
//    RTFixedTimeSource *theTime = [[RTFixedTimeSource alloc] initWithTime:[NSDate dateWithTimeIntervalSinceReferenceDate:-3012]];
    roseTime = [[RoseTime alloc] initWithTimeSource:theTime];
    [theTime release];
    
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc;
{
    [tabBarController release];
    [window release];
    [roseTime release];
    [super dealloc];
}

@end

