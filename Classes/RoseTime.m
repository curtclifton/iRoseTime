//
//  RoseTime.m
//  RoseTime
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import "RoseTime.h"
#import "RTTimeSource.h"

#define FIRST_BELL (8 * 60*60 + 5 * 60)
#define PERIODS_PER_DAY 10
#define PERIOD_LENGTH (50*60)
#define PASSING_PERIOD_LENGTH (5*60)
#define SECONDS_IN_A_DAY 86400
// Bell sync signal must be within BELL_SYNC_PRECISION * PASSING_PERIOD_LENGTH
// of an expected bell time.
#define BELL_SYNC_PRECISION 0.4

static NSString * const BELL_OFFSET_KEY = @"BellOffsetKey";

@interface RoseTime (helpers)
- (void)initializeFormatter;
- (void)initializeBellTimes;
@end

@implementation RoseTime
{
    NSTimeInterval _bellOffset;
    id <RTTimeSource> _timeSource;
    NSDateFormatter *_formatter;
    NSArray *_bellTimes; // Bell times in seconds since midnight, ascending
}

- (id)initWithTimeSource:(id <RTTimeSource>)aTimeSource bellOffset:(NSTimeInterval)offset;
{
    if (self = [super init]) {
        _timeSource = [aTimeSource retain];
        _bellOffset = offset;
        
        [self initializeFormatter];
        [self initializeBellTimes];
    }
    return self;
}

- (id)initWithTimeSource:(id <RTTimeSource>)aTimeSource;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *bellOffsetValue = [defaults objectForKey:BELL_OFFSET_KEY];
    
    return [self initWithTimeSource:aTimeSource bellOffset:[bellOffsetValue doubleValue]];
}

- (id)init;
{
    id<RTTimeSource> aTimeSource = [[RTActualTimeSource alloc] init];
    self = [self initWithTimeSource:aTimeSource];
    [aTimeSource release];
    return self;
}

- (void)dealloc;
{
    [_timeSource release];
    [_formatter release];
    [_bellTimes release];
    [super dealloc];
}

@synthesize bellOffset = _bellOffset;

- (void)setBellOffset:(NSTimeInterval)bellOffset;
{
    _bellOffset = bellOffset;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithDouble:bellOffset] forKey:BELL_OFFSET_KEY];
    [defaults synchronize];
}

- (NSInteger)secondsPastMidnightAtRose;
{
    // Adjust based on time in Terre Haute
    NSCalendar *cal = [_timeSource calendar];
    NSDate *now = [_timeSource currentTime];
    NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *currentComponents = [cal components:units
                                                 fromDate:now];
    NSInteger wholeOffset = round(self.bellOffset);
    NSInteger result = (currentComponents.hour * 60 + currentComponents.minute) * 60 + currentComponents.second - wholeOffset;
    if (result < 0) {		
        result += 86400;
    } else if (result > 86400) {
        result -= 86400;
    }
    return result;
}

- (NSInteger)secondsUntilNextBell;
{
    NSInteger secondsPastMidnightAtSchool = [self secondsPastMidnightAtRose];
    
    for (NSNumber *bellTime in _bellTimes) {
        NSInteger secondsUntilBell = [bellTime intValue] - secondsPastMidnightAtSchool;
        if (secondsUntilBell >= 0) {
            return secondsUntilBell;
        }
    }
    
    // If all are negative, then calculate the first value again and add 86400
    // (This value will be wrong on Friday night, Saturday, and Sunday before last bell time.)
    return [[_bellTimes objectAtIndex:0] intValue] - secondsPastMidnightAtSchool + SECONDS_IN_A_DAY;
}

- (NSString *)currentTimeAsString;
{
    NSDate *theDate = [_timeSource currentTime];
    NSDateComponents *adjustmentComponents = [[NSDateComponents alloc] init];
    adjustmentComponents.second = -1 * round(self.bellOffset);
    theDate = [[_timeSource calendar] dateByAddingComponents:adjustmentComponents
                                                          toDate:theDate 
                                                         options:0];
    [_formatter setTimeZone:[_timeSource timeZone]];
    return [_formatter stringFromDate:theDate];
}

- (BOOL)synchronizeToBell;
{
    NSDate *ringTime = [_timeSource currentTime];
    // Loop over bell times calculating new bell offset values
    // First offset less than a threshold is the new bell offset
    
    // Calculate seconds since midnight for ringTime to highest precision available
    NSCalendar *cal = [_timeSource calendar];
    NSUInteger units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;	
    NSDateComponents *comp = [cal components:units fromDate:ringTime];
    NSDate *midnightThisMorning = [cal dateFromComponents:comp];
    NSTimeInterval ringTimeInSecondsSinceMidnight = [ringTime timeIntervalSinceDate:midnightThisMorning];
    
    // bellOffset is how much the bells are late compared to device time,
    // so if ringTime is less than bell time, then bell rang early and offset 
    // should be negative.
    for (NSNumber *bellTime in _bellTimes) {
        NSTimeInterval newOffset = ringTimeInSecondsSinceMidnight - [bellTime doubleValue];
        if (abs(newOffset) < BELL_SYNC_PRECISION * PASSING_PERIOD_LENGTH) {
            self.bellOffset = newOffset;
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark Helper Methods

- (void)initializeFormatter;
{
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    [_formatter setDateStyle:NSDateFormatterNoStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [_formatter setLocale:usLocale];
    [usLocale release];
    [_formatter setAMSymbol:@"am"];
    [_formatter setPMSymbol:@"pm"];	
}

- (void)initializeBellTimes;
{
    NSMutableArray *bt = [NSMutableArray arrayWithCapacity:PERIODS_PER_DAY * 2];
    NSInteger nextBell = FIRST_BELL;
    for (int i=0; i < PERIODS_PER_DAY; i++) {
        [bt addObject:[NSNumber numberWithInt:nextBell]];
        nextBell += PERIOD_LENGTH;
        [bt addObject:[NSNumber numberWithInt:nextBell]];
        nextBell += PASSING_PERIOD_LENGTH;
    }
    _bellTimes = [[NSArray alloc] initWithArray:bt];
}

@end
