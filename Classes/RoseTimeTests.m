//
//  RoseTimeTests.m
//  RoseTime
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import "RoseTimeTests.h"
#import "RoseTime.h"

#define SECONDS_IN_A_HALF_HOUR (30*60)
#define SECONDS_IN_AN_HOUR (60*60)
#define DAYS_180 (180 * 24 * 60 * 60)
#define TEN_YEARS (10 * 365 * 24 * 60 * 60)
#define GMT_DIFF (6 * 60 * 60)

@implementation RoseTimeTests

- (void) setUp {
	NSLog(@"Setting up tests: %s", __FUNCTION__);
	oneAM_GMT = [self allocTimeSource:[NSDate dateWithTimeIntervalSinceReferenceDate:SECONDS_IN_AN_HOUR + TEN_YEARS]];
	oneAMDST_GMT = [self allocTimeSource:[NSDate dateWithTimeIntervalSinceReferenceDate:SECONDS_IN_AN_HOUR + DAYS_180 + TEN_YEARS]];
	eightAM = [self allocTimeSource:[NSDate dateWithTimeIntervalSinceReferenceDate:8*SECONDS_IN_AN_HOUR + GMT_DIFF +TEN_YEARS]];
	twoThirtyPM = [self allocTimeSource:
				   [NSDate dateWithTimeIntervalSinceReferenceDate:14*SECONDS_IN_AN_HOUR + SECONDS_IN_A_HALF_HOUR + GMT_DIFF + TEN_YEARS]];
	noon = [self allocTimeSource:[NSDate dateWithTimeIntervalSinceReferenceDate:12*SECONDS_IN_AN_HOUR + GMT_DIFF +TEN_YEARS]];
}

- (RTFixedTimeSource *)allocTimeSource:(NSDate *)time {
	return [[RTFixedTimeSource alloc] initWithTime:time];
}

- (void) tearDown {
	[oneAM_GMT release];
	[oneAMDST_GMT release];
	[eightAM release];
	[twoThirtyPM release];
	[noon release];
}

- (void) compareCurrentTimeAsStringWithTimeSource: (id <RTTimeSource>) timeSource
										 expected: (NSString *) expectedValue
											label: (NSString *) aLabel 
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:timeSource];
	NSString *actual = [time currentTimeAsString];
	STAssertEqualObjects(actual, expectedValue, aLabel);
	[time release];
}

- (void) compareCurrentTimeAsStringWithOffset: (NSTimeInterval) offset
										 expected: (NSString *) expectedValue
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:eightAM 
											   bellOffset:offset];
	NSString *actual = [time currentTimeAsString];
	STAssertEqualObjects(actual, expectedValue, 
						 @"Testing 8am in EST with %.2f second bell offset",
						 offset);
	[time release];
}

- (void) testCurrentTimeAsString {
	[self compareCurrentTimeAsStringWithTimeSource:oneAM_GMT 
										  expected:@"7:00 pm" 
											 label:@"Testing 1am GMT in EST"];
	[self compareCurrentTimeAsStringWithTimeSource:oneAMDST_GMT 
										  expected:@"8:00 pm" 
											 label:@"Testing 1am GMT in EDT"];
	[self compareCurrentTimeAsStringWithTimeSource:eightAM 
										  expected:@"8:00 am" 
											 label:@"Testing 8am in EST"];
	[self compareCurrentTimeAsStringWithTimeSource:twoThirtyPM 
										  expected:@"2:30 pm" 
											 label:@"Testing 2:30pm in EST"];
	[self compareCurrentTimeAsStringWithTimeSource:noon 
										  expected:@"12:00 pm" 
											 label:@"Testing noon in EST"];
	
	[self compareCurrentTimeAsStringWithOffset:61.2f expected:@"7:58 am"];
	[self compareCurrentTimeAsStringWithOffset:59.4f expected:@"7:59 am"];
	[self compareCurrentTimeAsStringWithOffset:-61.2f expected:@"8:01 am"];
	[self compareCurrentTimeAsStringWithOffset:1.4f expected:@"7:59 am"];
	[self compareCurrentTimeAsStringWithOffset:0.4f expected:@"8:00 am"];
}

- (void) compareSecondsUntilNextBellWithTimeSource:(id<RTTimeSource>) timeSource
										  expected:(NSInteger) expectedValue
											 label:(NSString *) aLabel 
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:timeSource];
	NSInteger actual = [time secondsUntilNextBell];
	STAssertEquals(actual, expectedValue, aLabel);
	[time release];	
}

- (void) compareSecondsUntilNextBellWithOffset:(NSTimeInterval) offset 
									  expected:(NSInteger)expectedValue 
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:eightAM bellOffset:offset];
	NSInteger actual = [time secondsUntilNextBell];
	STAssertEquals(actual, expectedValue, 
				   @"Testing seconds to bell from 8am with %.2f second bell offset", offset);
	[time release];	
}

- (void) testSecondsUntilNextBell {
	[self compareSecondsUntilNextBellWithTimeSource:eightAM
										   expected:60*5
											  label:@"Testing seconds to bell from 8am"];
	[self compareSecondsUntilNextBellWithTimeSource:twoThirtyPM
										   expected:0
											  label:@"Testing seconds to bell from 2:30pm"];
	[self compareSecondsUntilNextBellWithTimeSource:noon
										   expected:35*60
											  label:@"Testing seconds to bell from noon"];
	[self compareSecondsUntilNextBellWithTimeSource:oneAM_GMT
										   expected:13*60*60 + 5*60
											  label:@"Testing seconds to bell from 1am GMT in EST"];
	[self compareSecondsUntilNextBellWithTimeSource:oneAMDST_GMT
										   expected:12*60*60 + 5*60
											  label:@"Testing seconds to bell from 1am GMT in EDT"];
	
	[self compareSecondsUntilNextBellWithOffset:1.2 expected:60*5 + 1];
	[self compareSecondsUntilNextBellWithOffset:-1.2 expected:60*5 - 1];
	[self compareSecondsUntilNextBellWithOffset:1.6 expected:60*5 + 2];
	[self compareSecondsUntilNextBellWithOffset:-1.6 expected:60*5 - 2];
	
}

- (void) compareSecondsPastMidnightWithTimeSource:(id<RTTimeSource>) timeSource
										 expected:(NSInteger) expectedValue
											label:(NSString *) aLabel 
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:timeSource];
	NSInteger actual = [time secondsPastMidnightAtRose];
	STAssertEquals(actual, expectedValue, aLabel);
	[time release];	
}

- (void) compareSecondsPastMidnightWithOffset:(NSTimeInterval) offset 
									 expected:(NSInteger)expectedValue 
{
	RoseTime *time = [[RoseTime alloc] initWithTimeSource:eightAM bellOffset:offset];
	NSInteger actual = [time secondsPastMidnightAtRose];
	// NSLog(@" Actual: %d, Expected: %d", actual, expectedValue);
	STAssertEquals(actual, expectedValue, 
				   @"Testing seconds past midnight for 8am with %.2f second bell offset.",
				   offset);
	[time release];	
}

- (void) testSecondsPastMidnightAtRose {
	[self compareSecondsPastMidnightWithTimeSource:eightAM
										  expected:8*60*60
											 label:@"Testing seconds past midnight at 8 am"];
	[self compareSecondsPastMidnightWithTimeSource:twoThirtyPM
										  expected:14.5*60*60
											 label:@"Testing seconds past midnight at 2:30 pm"];
	[self compareSecondsPastMidnightWithTimeSource:noon
										  expected:12*60*60
											 label:@"Testing seconds past midnight at noon"];
	[self compareSecondsPastMidnightWithTimeSource:oneAM_GMT
										  expected:19*60*60
											 label:@"Testing seconds past midnight at 1am GMT in EST"];
	[self compareSecondsPastMidnightWithTimeSource:oneAMDST_GMT
										  expected:20*60*60
											 label:@"Testing seconds past midnight at 1am GMT in EDT"];
	[self compareSecondsPastMidnightWithOffset:1.2 expected:8*60*60 - 1];
	[self compareSecondsPastMidnightWithOffset:-1.2 expected:8*60*60 + 1];
	[self compareSecondsPastMidnightWithOffset:1.6 expected:8*60*60 - 2];
	[self compareSecondsPastMidnightWithOffset:-1.6 expected:8*60*60 + 2];
	
}

- (void) verifySyncAt:(NSTimeInterval)intervalSinceReference 
	expectedSecondsPastMidnight:(NSInteger) expectedSeconds
		 expectedTime:(NSString *) expectedString 
{
	NSDate *ring = [NSDate dateWithTimeIntervalSinceReferenceDate:intervalSinceReference];
	RTFixedTimeSource *ts = [self allocTimeSource:ring];
	RoseTime *rt = [[RoseTime alloc] initWithTimeSource:ts];
	STAssertTrue([rt synchronizeToBell], @"Should sync to a nearby time");
	// Check that seconds past midnight is correct
	// NSLog(@"seconds past midnight: %d", [rt secondsPastMidnightAtRose]);
	STAssertEquals([rt secondsPastMidnightAtRose], expectedSeconds,
				   @"After sync, time should be a bell time");
	// Check that seconds to bell is 0
	//	NSLog(@"seconds to next bell: %d", [rt secondsUntilNextBell]);
	STAssertEquals([rt secondsUntilNextBell], 0, 
				   @"After sync, seconds to next bell should be 0");
	// Check that current time is the right bell time
	STAssertEqualObjects([rt currentTimeAsString], 
						 expectedString, @"After sync, time should be a bell time");
	
}

- (void) verifyNoSyncAt:(NSTimeInterval)intervalSinceReference {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:intervalSinceReference];
	RTFixedTimeSource *ts = [[RTFixedTimeSource alloc] initWithTime:date];
	RoseTime *rt = [[RoseTime alloc] initWithTimeSource:ts];
	STAssertFalse([rt synchronizeToBell], @"Should not sync at %@", date);
}

- (void) testSynchronizeToBellAt {
	NSInteger expectedSecondsPast = 8 * SECONDS_IN_AN_HOUR + 5 * 60;
	NSInteger firstBell = expectedSecondsPast + GMT_DIFF + TEN_YEARS;
	// Give it a ringTime that's early
	[self verifySyncAt:firstBell - 10 expectedSecondsPastMidnight:expectedSecondsPast 
		  expectedTime:@"8:05 am"];
		
	// Give it a ringTime that's late
	[self verifySyncAt:firstBell + 40 expectedSecondsPastMidnight:expectedSecondsPast 
		  expectedTime:@"8:05 am"];
	
	// Shouldn't sync if a bell wouldn't have rung then
	[self verifyNoSyncAt:GMT_DIFF + TEN_YEARS];
	
	// Shouldn't sync exactly in the middle of a passing period
	[self verifyNoSyncAt:GMT_DIFF + TEN_YEARS + 9*SECONDS_IN_AN_HOUR + 2.5 * 60];
	
}

@end
