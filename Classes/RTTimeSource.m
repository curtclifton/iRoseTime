//
//  RTTimeSource.m
//  RoseTime
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import "RTTimeSource.h"

@implementation RTFixedTimeSource
@synthesize time;

- (id)initWithTime:(NSDate *)fixedTime;
{
    if (self = [super init]) {
        [fixedTime retain];
        time = fixedTime;
    }
    return self;
}

- (id)init;
{
    return [self initWithTime:[NSDate date]];
}

- (void)dealloc;
{
    [time release];
    [super dealloc];
}


- (NSDate *)currentTime;
{
    return self.time;
}

- (NSTimeZone *)timeZone;
{
    // Indiana EST or EDT depending on the date of the fixed time source.
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"America/Indiana/Indianapolis"];
    if ([tz isDaylightSavingTimeForDate:self.time]) {
        tz = [NSTimeZone timeZoneForSecondsFromGMT:-5*60*60];
    } else {
        tz = [NSTimeZone timeZoneForSecondsFromGMT:-6*60*60];
    }
    return tz;
}

- (NSCalendar *)calendar;
{
    NSCalendar *cal = [[NSCalendar alloc] 
                       initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[self timeZone]];
    [cal autorelease];
    return cal;
}

@end

@implementation RTActualTimeSource

- (NSDate *)currentTime;
{
    return [NSDate date];
}

- (NSTimeZone *)timeZone;
{
    return [NSTimeZone timeZoneWithName:@"America/Indiana/Indianapolis"];
}

- (NSCalendar *)calendar;
{
    NSCalendar *cal = [[NSCalendar alloc] 
                       initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[self timeZone]];
    [cal autorelease];
    return cal;
}
@end
