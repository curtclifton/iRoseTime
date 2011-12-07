//
//  RoseTime.h
//  RoseTime
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import <Foundation/Foundation.h>
#import "RTTimeSource.h"

@interface RoseTime : NSObject {
}

@property (nonatomic, assign) NSTimeInterval bellOffset;
@property (nonatomic, retain) id<RTTimeSource> timeSource;
@property (nonatomic, retain) NSDateFormatter *formatter;

// Bell times in seconds since midnight, ascending
@property (nonatomic, retain) NSArray *bellTimes;

// Bell offset is number of seconds that bell is later than device system time
- (id)initWithTimeSource:(id<RTTimeSource>)aTimeSource bellOffset:(NSTimeInterval)offset;
- (id)initWithTimeSource:(id<RTTimeSource>)aTimeSource;

- (NSInteger) secondsPastMidnightAtRose;
- (NSInteger) secondsUntilNextBell;
- (NSString *) currentTimeAsString;

- (BOOL) synchronizeToBell;

@end
