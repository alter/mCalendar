//
//  DRAViewController.m
//  mCalendar
//
//  Created by admin on 27.01.13.
//  Copyright (c) 2013 Roman 'alterpub' Dolgov. All rights reserved.
//

#import "DRAViewController.h"
UIActionSheet *pickerViewPopup;

@interface DRAViewController ()

@end

@implementation DRAViewController

-(void)updateTextField:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [NSTimeZone resetSystemTimeZone];
    NSTimeZone *gmtZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:gmtZone];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    
    if([_editStartDate isFirstResponder]){
        UIDatePicker *picker = (UIDatePicker*)_editStartDate.inputView;
        NSString *displayString   = [dateFormatter stringFromDate:picker.date];
        _editStartDate.text = [NSString stringWithFormat:@"%@",displayString];
    }
    
    if([_editEndDate isFirstResponder]){
        UIDatePicker *picker = (UIDatePicker*)_editEndDate.inputView;
        NSString *displayString   = [dateFormatter stringFromDate:picker.date];
        _editEndDate.text = [NSString stringWithFormat:@"%@",displayString];
    }
    
}

- (NSString *)convertDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *dt = [formatter stringFromDate:date];
    return dt;
}

- (void)viewDidLoad
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [NSTimeZone resetSystemTimeZone];
    NSTimeZone *gmtZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:gmtZone];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    NSString *displayString   = [dateFormatter stringFromDate:today];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [datePicker setDate:today];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [_editStartDate setInputView:datePicker];

    _editStartDate.text = displayString;
    
    NSDate *days_delta = [today dateByAddingTimeInterval:(5 * 24 * 60 * 60)];
    displayString   = [dateFormatter stringFromDate:days_delta];
    [datePicker setDate:days_delta];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [_editEndDate setInputView:datePicker];
    _editEndDate.text = displayString;
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent: @"mCalendarDB.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSLog(@"%@", _databasePath);
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_mCalendarDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS days(id int primary key, startdate text default NULL, enddate text default NULL);";
            
            if (sqlite3_exec(_mCalendarDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_mCalendarDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)getLastID {
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int idValue = 0;
    
    if (sqlite3_open(dbpath, &_mCalendarDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT id FROM days order by 1 desc limit 1;"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_mCalendarDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *idField = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, 0)];
                idValue = [ idField intValue];
            } else {
                NSLog(@"Match not found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_mCalendarDB);
    }
    return idValue;
}

- (IBAction)addStartDate:(id)sender {
    
    _startDate = _editStartDate.text;
    if ([_startDate length] == 0) {
        _startDate = @"Empty";
    }
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int idValue = [self getLastID];
    if (sqlite3_open(dbpath, &_mCalendarDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO days (id, startDate, endDate) VALUES (\"%d\", \"%@\", \"%@\");",
                               idValue + 1, _startDate, NULL];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_mCalendarDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"StartDate added");
            _editStartDate.text = @"";
            _startDate = @"";
            
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"%d", idValue]);
        }
        sqlite3_finalize(statement);
        sqlite3_close(_mCalendarDB);
    }
}

- (IBAction)addEndDate:(id)sender {
    
    _endDate = _editEndDate.text;
    if ([_endDate length] == 0) {
        _endDate = @"Empty";
    }
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    int idValue = [self getLastID];
    if (sqlite3_open(dbpath, &_mCalendarDB) == SQLITE_OK)
    {
        NSString *updateSQL = [NSString stringWithFormat:
                               @"update days set enddate=\"%@\" where id=%d;", _endDate, idValue];
        NSLog(@"%@", updateSQL);
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(_mCalendarDB, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            _editEndDate.text = @"";
            _endDate = @"";
            
        } else {
            NSLog(@"Failed to update record");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_mCalendarDB);
    }
}

@end
