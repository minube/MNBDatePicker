//
//  MNBDatePickerView.h
//  MNDatePicker
//
//  Created by Ruben on 27/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNBDatePickerViewDelegate <NSObject>
@optional
- (void)mnbDatePickerDidChangeSelectionWithFirstSelectedDate:(NSDate *)firstSelectedDate lastSelectedDate:(NSDate *)lastSelectedDate;
- (void)mnbDatePickerDidSelectANonValidDateWithCurrentFirstSelectedDate:(NSDate *)firstSelectedDate lastSelectedDate:(NSDate *)lastSelectedDate;
- (void)mnbDatePickerDidCancelSelection;
@end

@interface MNBDatePickerView : UIView
@property (nonatomic, strong) UIColor *backgroundColor; // Main background color
@property (nonatomic, strong) NSDate *firstDate; // Initial date to show in the calendar
@property (nonatomic, strong) NSDate *lastDate; // Last date to show in the calendar
@property (nonatomic, strong) NSDate *firstPreSelectedDate; // Initial first selected date
@property (nonatomic, strong) NSDate *lastPreSelectedDate; // Initia last selected date - This must be latter than firstChoosenDate, if not only first choosen date will be show
@property (nonatomic, assign) BOOL sameNumberOfWeeksPerMonth; // Setting this value to YES makes to have the same number of items for every month
@property (nonatomic, assign) BOOL showDaysOnlyBelongsToMonth; // Setting this value to YES makes to hidde days that not belong to the month
@property (nonatomic, assign) id<MNBDatePickerViewDelegate> delegate;
@end
