//
//  MNBDatePickerViewHeader.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerViewHeader.h"

static const CGFloat MNBDatePickerHeaderTextSize = 20.0f;
static const CGFloat MNBDatePickerWeekDaysFontSize = 15.0f;

@interface MNBDatePickerViewHeader ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MNBDatePickerViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self initView];
    [self initTitleLabel];
    [self initWeekDaysLabels];
}

- (void)initView
{
    self.backgroundColor = [UIColor yellowColor];
}

- (void)initTitleLabel
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:MNBDatePickerHeaderTextSize];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)initWeekDaysLabels
{
    // First WeekDay
    UILabel *firstWeekDayLabel = [[UILabel alloc] init];
    firstWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    firstWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    firstWeekDayLabel.backgroundColor = [UIColor clearColor];
    firstWeekDayLabel.text = @"L";
    firstWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:firstWeekDayLabel];
    
    // Second WeekDay
    UILabel *secondWeekDayLabel = [[UILabel alloc] init];
    secondWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    secondWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    secondWeekDayLabel.backgroundColor = [UIColor clearColor];
    secondWeekDayLabel.text = @"M";
    secondWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:secondWeekDayLabel];
    
    // Third WeekDay
    UILabel *thirdWeekDayLabel = [[UILabel alloc] init];
    thirdWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    thirdWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    thirdWeekDayLabel.backgroundColor = [UIColor clearColor];
    thirdWeekDayLabel.text = @"X";
    thirdWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:thirdWeekDayLabel];
    
    // Forth WeekDay
    UILabel *forthWeekDayLabel = [[UILabel alloc] init];
    forthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    forthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    forthWeekDayLabel.backgroundColor = [UIColor clearColor];
    forthWeekDayLabel.text = @"J";
    forthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:forthWeekDayLabel];
    
    // Fifth WeekDay
    UILabel *fifthWeekDayLabel = [[UILabel alloc] init];
    fifthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    fifthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    fifthWeekDayLabel.backgroundColor = [UIColor clearColor];
    fifthWeekDayLabel.text = @"V";
    fifthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:fifthWeekDayLabel];
    
    // Sixth WeekDay
    UILabel *sixthWeekDayLabel = [[UILabel alloc] init];
    sixthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    sixthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    sixthWeekDayLabel.backgroundColor = [UIColor clearColor];
    sixthWeekDayLabel.text = @"S";
    sixthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:sixthWeekDayLabel];
    
    // Seventh WeekDay
    UILabel *seventhWeekDayLabel = [[UILabel alloc] init];
    seventhWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    seventhWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    seventhWeekDayLabel.backgroundColor = [UIColor clearColor];
    seventhWeekDayLabel.text = @"D";
    seventhWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:seventhWeekDayLabel];
    
    NSString *visualFormatHorizontalConstraint = @"H:|[firstWeekDayLabel]-2-[secondWeekDayLabel(==firstWeekDayLabel)]-2-[thirdWeekDayLabel(==firstWeekDayLabel)]-2-[forthWeekDayLabel(==firstWeekDayLabel)]-2-[fifthWeekDayLabel(==firstWeekDayLabel)]-2-[sixthWeekDayLabel(==firstWeekDayLabel)]-2-[seventhWeekDayLabel(==firstWeekDayLabel)]|";
    NSDictionary *horizontalViewsDictionary = NSDictionaryOfVariableBindings (firstWeekDayLabel, secondWeekDayLabel, thirdWeekDayLabel, forthWeekDayLabel, fifthWeekDayLabel, sixthWeekDayLabel, seventhWeekDayLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormatHorizontalConstraint options:NSLayoutFormatAlignAllBottom metrics:nil views:horizontalViewsDictionary]];
    
    NSString *visualVerticalFormatConstraint = @"V:[firstWeekDayLabel]|";
    NSDictionary *verticalViewsDictionary = NSDictionaryOfVariableBindings (firstWeekDayLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualVerticalFormatConstraint options:NSLayoutFormatAlignAllBottom metrics:nil views:verticalViewsDictionary]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.text = @"";
}

#pragma mark - Setters
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}
@end
