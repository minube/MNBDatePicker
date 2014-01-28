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
@property (nonatomic, strong) UIView *firstSelectedDayView;
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
    [self initFirstDayView];
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

- (void)initFirstDayView
{
    self.firstSelectedDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, self.bounds.size.width + 9.0f, self.bounds.size.height)];
    self.firstSelectedDayView.backgroundColor = [UIColor clearColor];
    self.firstSelectedDayView.clipsToBounds = YES;
    self.firstSelectedDayView.alpha = 0.0f;
    
    UIView *squareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, self.firstSelectedDayView.bounds.size.width - 9.0f, self.firstSelectedDayView.bounds.size.height)];
    squareView.backgroundColor = colorWithRGBA(244, 129, 0, 1.0f);
    [self.firstSelectedDayView addSubview:squareView];
    
    MNBTriangleView *triangle = [[MNBTriangleView alloc] initWithFrame:CGRectMake(self.firstSelectedDayView.bounds.size.width - 9.0f, 0.0f, 9.0f, self.firstSelectedDayView.bounds.size.height) color:colorWithRGBA(244, 129, 0, 1.0f)];
    [self.firstSelectedDayView addSubview:triangle];
    
    [self.contentView insertSubview:self.firstSelectedDayView belowSubview:self.dayLabel];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dayLabel.text = @"";
}

#pragma mark - Setters
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}

- (void)setIsSelectedDay:(BOOL)isSelectedDay
{
    if (isSelectedDay) {
        self.backgroundColor = colorWithRGBA(248, 168, 68, 1.0f);
    } else {
        self.backgroundColor = colorWithRGBA(39, 44, 51, 1.0f);
    }
}

- (void)setDayNumber:(NSString *)dayNumber
{
    self.dayLabel.text = dayNumber;
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay
{
    [self setIsFirstSelectedDay:isFirstSelectedDay animated:NO];
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated
{
    [self setIsFirstSelectedDay:isFirstSelectedDay animated:animated completion:nil];
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    self.dayLabel.font = isFirstSelectedDay ? [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize] : [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
    [UIView animateWithDuration:animated ? 0.2f : 0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.firstSelectedDayView.alpha = isFirstSelectedDay ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(YES);
        }
    }];
}

@end
