//
//  MNBDatePickerViewCell.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerViewCell.h"
#import "MNBTriangleView.h"

@interface MNBDatePickerViewCell ()
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) MNBTriangleView *triangle;
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
    [self initCell];
    [self initDayLabel];
    [self initTriangle];
}

- (void)initCell
{
    self.backgroundColor = colorWithRGBA(39, 44, 51, 1.0f);
}

- (void)initDayLabel
{
    _dayLabel = [[UILabel alloc] init];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.backgroundColor = [UIColor clearColor];
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    self.dayLabel.textColor = colorWithRGBA(255, 255, 255, 0.9f);
    [self.contentView addSubview:self.dayLabel];
    
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)initTriangle
{
    self.triangle = [[MNBTriangleView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0.0f, 9.0f, self.bounds.size.height) color:colorWithRGBA(248, 168, 68, 1.0f)];
    [self addSubview:self.triangle];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dayLabel.text = @"";
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = colorWithRGBA(248, 168, 68, 1.0f);
    } else {
        self.backgroundColor = colorWithRGBA(39, 44, 51, 1.0f);
    }
}

#pragma mark - Setters
- (void)setDayNumber:(NSString *)dayNumber
{
    self.dayLabel.text = dayNumber;
}

@end
