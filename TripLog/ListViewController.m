//
//  listViewController.m
//  TripLog
//
//  Created by Yinan Na on 1/24/15.
//  Copyright (c) 2015 com.lyft.ynn. All rights reserved.
//

#import "ListViewController.h"
#import "LogEntry.h"
#import "LogEntryCell.h"
#import "ControlCell.h"
#import <CoreLocation/CoreLocation.h>

@interface ListViewController () <CLLocationManagerDelegate>

@end

@implementation ListViewController {
  NSMutableArray *_logs;
  CLLocationManager *_locationManager;
  CLGeocoder *_geoCoder;
  NSTimer *_repeatTimer;
  
  BOOL _started;
  BOOL _enabled;
  CLLocation *_startLocation;
  NSString *_startAddress;
  NSDate *_startTime;
  CLLocation *_lastLocation;
  NSString *_lastAddress;
  NSDate *_lastTime;
}

static const NSUInteger kStillTimeThresInSecs = 60;
static const float kMovingSpeedThresInMPH = 10;
static const float kDistanceFilter = 10.0f;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar"]];
  self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
  self.navigationItem.titleView.frame = CGRectMake(0,0,45,42);
  
  _logs = [[NSMutableArray alloc] init];
  _geoCoder = [[CLGeocoder alloc] init];
  
  // Load control switch state from plist.
  NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled"];
  if (!val) {
    _enabled = YES;
  } else {
    _enabled = [val isEqualToString:@"YES"] ? YES : NO;
  }

  if (_enabled) {
    [self _startStandardUpdates];
  }
}

#pragma mark - Private
- (void)_startStandardUpdates {
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }
  if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    [_locationManager requestAlwaysAuthorization];
  }
  _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  _locationManager.distanceFilter = kDistanceFilter;
  [_locationManager startUpdatingLocation];
}

- (void)_stopStandardUpdates {
  _started = NO;
  [_locationManager stopUpdatingLocation];
  [self _stopRepeatingTimer];
}

- (void)_startRepeatingTimer {
  
  [_repeatTimer invalidate];
  
  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self selector:@selector(_stopIfNeeded)
                                                  userInfo:nil repeats:YES];
  _repeatTimer = timer;
}

- (void)_stopRepeatingTimer {
  [_repeatTimer invalidate];
  _repeatTimer = nil;
}

// checks and stops the trip if it's ended.
- (void)_stopIfNeeded {
  if ([[NSDate date] timeIntervalSinceDate:_lastTime] > kStillTimeThresInSecs && _started && _enabled) {
    NSLog(@"### trip ended");
    [_geoCoder reverseGeocodeLocation:_lastLocation completionHandler:^(NSArray* placemarks, NSError* error){
      if ([placemarks count] > 0) {
        _lastAddress = [(CLPlacemark *)[placemarks objectAtIndex:0] name];
      }
      _started = NO;
      LogEntry *logEntry = [[LogEntry alloc] initWithStartLocation:_startLocation
                                                       endLocation:_lastLocation
                                                      startAddress:_startAddress
                                                        endAddress:_lastAddress
                                                         startTime:_startTime
                                                           endTime:_lastTime];
      [_logs addObject:logEntry];
      [self.tableView reloadData];
    }];
    [self _stopRepeatingTimer];
  }
}

// helper function
- (NSString *)_timeRangeWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime {
  NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
  [timeFormatter setDateFormat:@"hh:mm a"];
  NSString *startStr = [timeFormatter stringFromDate:startTime];
  NSString *endStr = [timeFormatter stringFromDate:endTime];
  NSTimeInterval secsBetweenDates = [endTime timeIntervalSinceDate:startTime];
  
  NSString *timeRange;
  if (secsBetweenDates < 60) {
    timeRange = [NSString stringWithFormat:@"%@-%@ (%isec)", startStr, endStr, (int)secsBetweenDates];
  } else {
    NSInteger minsBetweenDates = secsBetweenDates / 60;
    timeRange = [NSString stringWithFormat:@"%@-%@ (%imin)", startStr, endStr, (int)minsBetweenDates];
  }
  return timeRange;
}

#pragma mark - Action
- (IBAction)switchTapped:(id)sender {
  if ([(UISwitch *)sender isOn]) {
    [self _startStandardUpdates];
    _enabled = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"enabled"];
  } else {
    _enabled = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"enabled"];
  }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation* currentLocation = [locations lastObject];
  NSDate* currentTime = currentLocation.timestamp;
  
  if (currentLocation.speed > kMovingSpeedThresInMPH && !_started && _enabled) {
    NSLog(@"### trip started");
    _started = YES;
    _startLocation = currentLocation;
    _startTime = currentTime;
    [_geoCoder reverseGeocodeLocation:_startLocation completionHandler:^(NSArray* placemarks, NSError* error){
      if ([placemarks count] > 0) {
        _startAddress = [(CLPlacemark *)[placemarks objectAtIndex:0] name];
      }
    }];
    [self _startRepeatingTimer];
  }
  
  _lastTime = currentTime;
  _lastLocation = currentLocation;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_logs count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    ControlCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ControlCell" forIndexPath:indexPath];
    if (cell == nil) {
      cell = [[ControlCell alloc] init];
    }
    [(UISwitch *)cell.controlSwitch setOn:_enabled];
    return cell;
  } else {
    LogEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryCell" forIndexPath:indexPath];
    if (cell == nil) {
      cell = [[LogEntryCell alloc] init];
    }
    LogEntry *entry = _logs[indexPath.row-1];
    cell.routeLabel.text = [NSString stringWithFormat:@"%@ > %@", entry.startAddress, entry.endAddress];
    cell.timeLabel.text = [self _timeRangeWithStartTime:entry.startTime endTime:entry.endTime];
    
    return cell;
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    return 70;
  } else {
    return 60;
  }
}

@end
