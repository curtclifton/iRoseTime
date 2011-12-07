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
- (void) initializeFormatter;
- (void) initializeBellTimes;
@end

@implementation RoseTime
{
    NSTimeInterval _bellOffset;
}

@synthesize bellOffset = _bellOffset;

- (void)setBellOffset:(NSTimeInterval)bellOffset;
{
    _bellOffset = bellOffset;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithDouble:bellOffset] forKey:BELL_OFFSET_KEY];
    [defaults synchronize];
}

@synthesize timeSource;
@synthesize formatter;
@synthesize bellTimes;

- (id)initWithTimeSource:(id<RTTimeSource>)aTimeSource bellOffset:(NSTimeInterval)offset;
{
    if (self = [super init]) {
        self.timeSource = aTimeSource;
        _bellOffset = offset;
        
        [self initializeFormatter];
        [self initializeBellTimes];
    }
    return self;
}

- (id)initWithTimeSource:(id<RTTimeSource>)aTimeSource;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *bellOffsetValue = [defaults objectForKey:BELL_OFFSET_KEY];

    return [self initWithTimeSource:aTimeSource bellOffset:[bellOffsetValue doubleValue]];
}

- (NSInteger) secondsPastMidnightAtRose {
    // Adjust based on time in Terre Haute
    NSCalendar *cal = [self.timeSource calendar];
    NSDate *now = [self.timeSource currentTime];
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

- (NSInteger) secondsUntilNextBell {
    NSInteger secondsPastMidnightAtSchool = [self secondsPastMidnightAtRose];
    //NSLog(@"======> Seconds since midnight: %d", secondsPastMidnightAtSchool);
    
    for (NSNumber *bellTime in self.bellTimes) {
        NSInteger secondsUntilBell = [bellTime intValue] - secondsPastMidnightAtSchool;
        if (secondsUntilBell >= 0) {
            return secondsUntilBell;
        }
    }
    
    // If all are negative, then calculate the first value again and add 86400
    // (This value will be wrong on Friday night, Saturday, and Sunday before last bell time.)
    return [[self.bellTimes objectAtIndex:0] intValue] - secondsPastMidnightAtSchool + SECONDS_IN_A_DAY;
}

- (NSString *) currentTimeAsString {
    NSDate *theDate = [self.timeSource currentTime];
    NSDateComponents *adjustmentComponents = [[NSDateComponents alloc] init];
    adjustmentComponents.second = -1 * round(self.bellOffset);
    theDate = [[self.timeSource calendar] dateByAddingComponents:adjustmentComponents
                                                          toDate:theDate 
                                                         options:0];
    [formatter setTimeZone:[self.timeSource timeZone]];
    //	NSLog(@"formatter's time zone is %@", [formatter timeZone]);
    //	NSLog(@"====> adjustment: %d", adjustmentComponents.second);
    //	NSLog(@"theDate is %@", theDate);
    //	NSLog(@"formatted: %@", [formatter stringFromDate:theDate]);
    return [formatter stringFromDate:theDate];
}

- (BOOL)synchronizeToBell;
{
    NSDate *ringTime = [self.timeSource currentTime];
    // Loop over bell times calculating new bell offset values
    // First offset less than a threshold is the new bell offset
    //	NSLog(@"====> ringTime: %@", ringTime);
    
    // Calculate seconds since midnight for ringTime to highest precision available
    NSCalendar *cal = [self.timeSource calendar];
    NSUInteger units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;	
    NSDateComponents *comp = [cal components:units fromDate:ringTime];
    NSDate *midnightThisMorning = [cal dateFromComponents:comp];
    //	NSLog(@"midnight: %@", midnightThisMorning);
    NSTimeInterval ringTimeInSecondsSinceMidnight = [ringTime timeIntervalSinceDate:midnightThisMorning];
    //	NSLog(@"ringTime since midnight: %f", ringTimeInSecondsSinceMidnight);
    
    // bellOffset is how much the bells are late compared to device time,
    // so if ringTime is less than bell time, then bell rang early and offset 
    // should be negative.
    for (NSNumber *bellTime in self.bellTimes) {
        NSTimeInterval newOffset = ringTimeInSecondsSinceMidnight - [bellTime doubleValue];
        if (abs(newOffset) < BELL_SYNC_PRECISION * PASSING_PERIOD_LENGTH) {
            // NSLog(@"new offset: %f", newOffset);
            self.bellOffset = newOffset;
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark Helper Methods

- (void) initializeFormatter {
    self.formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [usLocale release];
    [formatter setLocale:usLocale];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];	
}

- (void) initializeBellTimes {
    NSMutableArray *bt = [NSMutableArray arrayWithCapacity:PERIODS_PER_DAY * 2];
    NSInteger nextBell = FIRST_BELL;
    for (int i=0; i < PERIODS_PER_DAY; i++) {
        [bt addObject:[NSNumber numberWithInt:nextBell]];
        nextBell += PERIOD_LENGTH;
        [bt addObject:[NSNumber numberWithInt:nextBell]];
        nextBell += PASSING_PERIOD_LENGTH;
    }
    self.bellTimes = bt;
    //	NSLog(@"==========> bellTimes: %@", bt);
}

#pragma mark -
#pragma mark NSObject Overrides
- (id) init {
    id<RTTimeSource> aTimeSource = [[RTActualTimeSource alloc] init];
    id result = [self initWithTimeSource:aTimeSource];
    [aTimeSource release];
    return result;
}

- (void) dealloc {
    [timeSource release];
    [formatter release];
    [bellTimes release];
    [super dealloc];
}

@end
