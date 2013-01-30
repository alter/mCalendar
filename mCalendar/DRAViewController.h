//
//  DRAViewController.h
//  mCalendar
//
//  Created by admin on 27.01.13.
//  Copyright (c) 2013 Roman 'alterpub' Dolgov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface DRAViewController : UIViewController
- (IBAction)addStartDate:(id)sender;
- (IBAction)addEndDate:(id)sender;

@property (weak, nonatomic ) IBOutlet UITextField *editStartDate;
@property (weak, nonatomic ) IBOutlet UITextField *editEndDate;

@property ( copy, nonatomic ) NSString *startDate;
@property ( copy, nonatomic ) NSString *endDate;

// database
@property ( strong, nonatomic ) NSString *databasePath;
@property ( nonatomic ) sqlite3 *mCalendarDB;

@property ( strong, nonatomic ) UIPickerView *datePickView;
@property ( strong, nonatomic ) UIToolbar *pickerBar;


@end
