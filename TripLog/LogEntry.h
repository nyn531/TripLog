//
//  logEntry.h
//  TripLog
//
//  Created by Yinan Na on 1/24/15.
//  Copyright (c) 2015 com.lyft.ynn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LogEntry : NSObject

@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *endLocation;
@property (strong, nonatomic) NSString *startAddress;
@property (strong, nonatomic) NSString *endAddress;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

- (instancetype) initWithStartLocation:(CLLocation *)startLocation
                           endLocation:(CLLocation *)endLocation
                          startAddress:(NSString *)startAddress
                            endAddress:(NSString *)endAddress
                             startTime:(NSDate *)startTime
                               endTime:(NSDate *)endTime;

@end
