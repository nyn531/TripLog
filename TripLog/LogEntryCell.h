//
//  LogEntryCell.h
//  TripLog
//
//  Created by Yinan Na on 1/24/15.
//  Copyright (c) 2015 com.lyft.ynn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogEntryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
