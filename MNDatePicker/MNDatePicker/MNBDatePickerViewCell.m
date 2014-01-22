//
//  MNBDatePickerViewCell.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerViewCell.h"

@interface MNBDatePickerViewCell ()
@property (nonatomic, strong) UILabel *dayLabel;
@end

@implementation MNBDatePickerViewCell

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
    [self initDayLabel];
}

- (void)initDayLabel
{
    _dayLabel = [[UILabel alloc] init];
    [self.dayLabel setTextAlignment:NSTextAlignmentCenter];
    self.dayLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dayLabel];
    
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dayLabel.text = @"";
}

#pragma mark - Setters
- (void)setDayNumber:(NSString *)dayNumber
{
    self.dayLabel.text = dayNumber;
}

@end
