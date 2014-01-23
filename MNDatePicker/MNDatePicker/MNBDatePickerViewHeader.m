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
@property (nonatomic, strong) UILabel *firstWeekDayLabel;
@property (nonatomic, strong) UILabel *secondWeekDayLabel;
@property (nonatomic, strong) UILabel *thirdWeekDayLabel;
@property (nonatomic, strong) UILabel *forthWeekDayLabel;
@property (nonatomic, strong) UILabel *fifthWeekDayLabel;
@property (nonatomic, strong) UILabel *sixthWeekDayLabel;
@property (nonatomic, strong) UILabel *seventhWeekDayLabel;
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
    firstWeekDayLabel.text = @"";
    firstWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:firstWeekDayLabel];
    self.firstWeekDayLabel = firstWeekDayLabel;
    
    // Second WeekDay
    UILabel *secondWeekDayLabel = [[UILabel alloc] init];
    secondWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    secondWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    secondWeekDayLabel.backgroundColor = [UIColor clearColor];
    secondWeekDayLabel.text = @"";
    secondWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:secondWeekDayLabel];
    self.secondWeekDayLabel = secondWeekDayLabel;
    
    // Third WeekDay
    UILabel *thirdWeekDayLabel = [[UILabel alloc] init];
    thirdWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    thirdWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    thirdWeekDayLabel.backgroundColor = [UIColor clearColor];
    thirdWeekDayLabel.text = @"";
    thirdWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:thirdWeekDayLabel];
    self.thirdWeekDayLabel = thirdWeekDayLabel;
    
    // Forth WeekDay
    UILabel *forthWeekDayLabel = [[UILabel alloc] init];
    forthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    forthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    forthWeekDayLabel.backgroundColor = [UIColor clearColor];
    forthWeekDayLabel.text = @"";
    forthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:forthWeekDayLabel];
    self.forthWeekDayLabel = forthWeekDayLabel;
    
    // Fifth WeekDay
    UILabel *fifthWeekDayLabel = [[UILabel alloc] init];
    fifthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    fifthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    fifthWeekDayLabel.backgroundColor = [UIColor clearColor];
    fifthWeekDayLabel.text = @"";
    fifthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:fifthWeekDayLabel];
    self.fifthWeekDayLabel = fifthWeekDayLabel;
    
    // Sixth WeekDay
    UILabel *sixthWeekDayLabel = [[UILabel alloc] init];
    sixthWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    sixthWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    sixthWeekDayLabel.backgroundColor = [UIColor clearColor];
    sixthWeekDayLabel.text = @"";
    sixthWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:sixthWeekDayLabel];
    self.sixthWeekDayLabel = sixthWeekDayLabel;
    
    // Seventh WeekDay
    UILabel *seventhWeekDayLabel = [[UILabel alloc] init];
    seventhWeekDayLabel.font = [UIFont systemFontOfSize:MNBDatePickerWeekDaysFontSize];
    seventhWeekDayLabel.textAlignment = NSTextAlignmentCenter;
    seventhWeekDayLabel.backgroundColor = [UIColor clearColor];
    seventhWeekDayLabel.text = @"";
    seventhWeekDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:seventhWeekDayLabel];
    self.seventhWeekDayLabel = seventhWeekDayLabel;
    
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

- (void)setWeekDays:(NSArray *)weekDays
{
    if (_weekDays != weekDays) {
        _weekDays = weekDays;
        if (_weekDays.count == 7) {
            self.firstWeekDayLabel.text = [_weekDays[0] uppercaseString];
            self.secondWeekDayLabel.text = [_weekDays[1] uppercaseString];
            self.thirdWeekDayLabel.text = [_weekDays[2] uppercaseString];
            self.forthWeekDayLabel.text = [_weekDays[3] uppercaseString];
            self.fifthWeekDayLabel.text = [_weekDays[4] uppercaseString];
            self.sixthWeekDayLabel.text = [_weekDays[5] uppercaseString];
            self.seventhWeekDayLabel.text = [_weekDays[6] uppercaseString];
        }
    }
}

@end
