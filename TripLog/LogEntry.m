//
//  logEntry.m
//  TripLog
//
//  Created by Yinan Na on 1/24/15.
//  Copyright (c) 2015 com.lyft.ynn. All rights reserved.
//

#import "LogEntry.h"

@implementation LogEntry

- (instancetype) initWithStartLocation:(CLLocation *)startLocation
                           endLocation:(CLLocation *)endLocation
                          startAddress:(NSString *)startAddress
                            endAddress:(NSString *)endAddress
                             startTime:(NSDate *)startTime
                               endTime:(NSDate *)endTime
{
  self = [super init];
  if (self) {
    _startLocation = startLocation;
    _endLocation = endLocation;
    _startAddress = startAddress;
    _endAddress = endAddress;
    _startTime = startTime;
    _endTime = endTime;
  }
  return self;
}

@end
