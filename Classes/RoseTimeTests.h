//
//  RoseTimeTests.h
//  RoseTime
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010 Computer Science and Software Engineering, Rose-Hulman Institute of Technology. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "RTTimeSource.h"

@interface RoseTimeTests : SenTestCase {
	id<RTTimeSource> oneAM_GMT;
	id<RTTimeSource> oneAMDST_GMT;
	id<RTTimeSource> eightAM;
	id<RTTimeSource> twoThirtyPM;
	id<RTTimeSource> noon;
}

- (RTFixedTimeSource *)allocTimeSource:(NSDate *)time;

@end
