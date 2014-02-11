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
- (void)mnbDatePickerDidChangeSelection;
- (void)mnbDatePickerDidCancelSelection;
@end

@interface MNBDatePickerView : UIView
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong, readonly) NSDate *firstChoosenDate;
@property (nonatomic, strong, readonly) NSDate *lastChoosenDate;
@property (nonatomic, assign) BOOL sameNumberOfWeeksPerMonth; // Setting this value to YES makes to have the same number of items for every month
@property (nonatomic, assign) BOOL showDaysOnlyBelongsToMonth; // Setting this value to YES makes to hidde days that not belong to the month
@property (nonatomic, assign) id<MNBDatePickerViewDelegate> delegate;
@end
