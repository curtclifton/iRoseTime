//
//  RTTimeSource.h
//  RoseTime
//
//  This protocol is implemented by classes that can provide an NSDate object
//  in response to a currentTime request.  This is primarily for testing. In
//  production code, a thin wrapper on [NSDate date] fills the role of
//  RTTimeSource.  For testing, we create lightweight classes to return a 
//  constant NSDate.
//
//  Created by Curtis Clifton on 9/26/10.
//  Copyright 2010-11 by Curtis Clifton
//  Released under a BSD license
//

#import <Foundation/Foundation.h>


@protocol RTTimeSource <NSObject>
- (NSDate *) currentTime;
- (NSTimeZone *) timeZone;
- (NSCalendar *) calendar;
@end

@interface RTFixedTimeSource : NSObject <RTTimeSource>
@property (nonatomic, readonly) NSDate *time;
- (id) initWithTime: (NSDate *) fixedTime;
@end

@interface RTActualTimeSource : NSObject <RTTimeSource>
@end


