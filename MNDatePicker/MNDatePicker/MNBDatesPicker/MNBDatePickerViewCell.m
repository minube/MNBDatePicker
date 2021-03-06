//
//  MNBDatePickerViewCell.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerViewCell.h"
#import "MNBTriangleView.h"

static NSString * const MNBDatePickerViewCellBounceInAnimationKey = @"MNBDatePickerViewCellBounceInAnimation";
static NSString * const MNBDatePickerViewCellBounceOutAnimationKey = @"MNBDatePickerViewCellBounceOutAnimation";

typedef void (^MNBDatePickerViewCellCompletionCallback)(BOOL finished);

@interface MNBDatePickerViewCell ()<CAAnimationDelegate>
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UIView *firstSelectedDayView;
@property (nonatomic, strong) UIView *lastSelectedDayView;
@property (nonatomic, copy) MNBDatePickerViewCellCompletionCallback completion;
@end

@implementation MNBDatePickerViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setUpCell];
    [self setUpDayLabel];
    [self setUpFirstSelectedDayView];
    [self setUpLastSelectedDayView];
}

- (void)setUpCell {
    self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
}

- (void)setUpDayLabel {
    _dayLabel = [[UILabel alloc] init];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.backgroundColor = [UIColor clearColor];
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    self.dayLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.dayLabel];
    
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

- (void)setUpFirstSelectedDayView {
    self.firstSelectedDayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width + 11.0f, self.bounds.size.height)];
    self.firstSelectedDayView.backgroundColor = [UIColor clearColor];
    self.firstSelectedDayView.clipsToBounds = YES;
    self.firstSelectedDayView.alpha = 0.0f;
    
    UIView *squareView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.firstSelectedDayView.bounds.size.width - 11.0f, self.firstSelectedDayView.bounds.size.height)];
    squareView.backgroundColor = [UIColor colorWithRed:244/255.0 green:129/255.0 blue:0/255.0 alpha:1.0];
    [self.firstSelectedDayView addSubview:squareView];
    
    MNBTriangleView *triangle = [[MNBTriangleView alloc] initWithFrame:CGRectMake(self.firstSelectedDayView.bounds.size.width - 11.0f, 0.0f, 11.0f, self.firstSelectedDayView.bounds.size.height) color:[UIColor colorWithRed:244/255.0 green:129/255.0 blue:0/255.0 alpha:1.0]];
    [self.firstSelectedDayView addSubview:triangle];
    
    [self.contentView insertSubview:self.firstSelectedDayView belowSubview:self.dayLabel];
}

- (void)setUpLastSelectedDayView {
    self.lastSelectedDayView = [[UIView alloc] initWithFrame:self.bounds];
    self.lastSelectedDayView.backgroundColor = [UIColor colorWithRed:244/255.0 green:129/255.0 blue:0/255.0 alpha:1.0];
    self.lastSelectedDayView.alpha = 0.0f;
    [self.contentView insertSubview:self.lastSelectedDayView belowSubview:self.dayLabel];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.dayLabel.text = @"";
}

#pragma mark - Setters
- (void)setIsSelectedDay:(BOOL)isSelectedDay {
    if (isSelectedDay) {
        self.backgroundColor = [UIColor colorWithRed:248/255.0 green:168/255.0 blue:68/255.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
    }
}

- (void)setIsDisableDay:(BOOL)isDisableDay {
    if (_isDisableDay != isDisableDay) {
        _isDisableDay = isDisableDay;
        self.dayLabel.textColor = _isDisableDay ? [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2] : [UIColor whiteColor];
    }
}

- (void)setDayNumber:(NSString *)dayNumber {
    self.dayLabel.text = dayNumber;
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay {
    if (_isFirstSelectedDay != isFirstSelectedDay) {
        _isFirstSelectedDay = isFirstSelectedDay;
        self.firstSelectedDayView.alpha = isFirstSelectedDay ? 1.0f : 0.0f;
        self.dayLabel.font = isFirstSelectedDay ? [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize] : [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
    }
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated {
    [self setIsFirstSelectedDay:isFirstSelectedDay animated:animated completion:nil];
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.completion = completion;
    if (isFirstSelectedDay) {
        if (animated) {
            [self startFirstSelectedDayBounceInAnimation];
        } else {
            self.isFirstSelectedDay = YES;
        }
    } else {
        if (animated) {
            [self startFirstSelectedDayBounceOutAnimation];
        } else {
            self.isFirstSelectedDay = NO;
        }
    }
}

- (void)setIsLastSelectedDay:(BOOL)isLastSelectedDay {
    if (_isLastSelectedDay != isLastSelectedDay) {
        _isLastSelectedDay = isLastSelectedDay;
        self.lastSelectedDayView.alpha = isLastSelectedDay ? 1.0f : 0.0f;
        self.dayLabel.font = isLastSelectedDay ? [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize] : [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
    }
}

- (void)setIsLastSelectedDay:(BOOL)isLastSelectedDay animated:(BOOL)animated {
    [self setIsLastSelectedDay:isLastSelectedDay animated:animated completion:nil];
}

- (void)setIsLastSelectedDay:(BOOL)isLastSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.completion = completion;
    if (isLastSelectedDay) {
        if (animated) {
            [self startLastSelectedDayBounceInAnimation];
        } else {
            self.isLastSelectedDay = YES;
        }
    } else {
        if (animated) {
            [self startLastSelectedDayBounceOutAnimation];
        } else {
            self.isLastSelectedDay = NO;
        }
    }
}

#pragma mark - Animations
- (void)startFirstSelectedDayBounceInAnimation {
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize];
    self.firstSelectedDayView.alpha = 1.0f;
    self.firstSelectedDayView.transform = CGAffineTransformIdentity;
    
    CGFloat initialScaleValue = 0.5f;
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.delegate = self;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:initialScaleValue],
                              [NSNumber numberWithFloat:1.1f],
                              [NSNumber numberWithFloat:0.8f],
                              [NSNumber numberWithFloat:1.0f], nil];
    bounceAnimation.duration = 0.3f;
    bounceAnimation.removedOnCompletion = NO;
    [self.firstSelectedDayView.layer addAnimation:bounceAnimation forKey:MNBDatePickerViewCellBounceInAnimationKey];
}

- (void)startFirstSelectedDayBounceOutAnimation {
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
    self.firstSelectedDayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.delegate = self;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0f],
                              [NSNumber numberWithFloat:0.0f], nil];
    bounceAnimation.duration = 0.1f;
    bounceAnimation.removedOnCompletion = NO;
    [self.firstSelectedDayView.layer addAnimation:bounceAnimation forKey:MNBDatePickerViewCellBounceOutAnimationKey];
}

- (void)startLastSelectedDayBounceInAnimation {
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize];
    self.lastSelectedDayView.alpha = 1.0f;
    self.lastSelectedDayView.transform = CGAffineTransformIdentity;
    
    CGFloat initialScaleValue = 0.5f;
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.delegate = self;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:initialScaleValue],
                              [NSNumber numberWithFloat:1.1f],
                              [NSNumber numberWithFloat:0.8f],
                              [NSNumber numberWithFloat:1.0f], nil];
    bounceAnimation.duration = 0.3f;
    bounceAnimation.removedOnCompletion = NO;
    [self.lastSelectedDayView.layer addAnimation:bounceAnimation forKey:MNBDatePickerViewCellBounceInAnimationKey];
}

- (void)startLastSelectedDayBounceOutAnimation {
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
    self.lastSelectedDayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.delegate = self;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0f],
                              [NSNumber numberWithFloat:0.0f], nil];
    bounceAnimation.duration = 0.1f;
    bounceAnimation.removedOnCompletion = NO;
    [self.lastSelectedDayView.layer addAnimation:bounceAnimation forKey:MNBDatePickerViewCellBounceOutAnimationKey];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if (animation == [self.firstSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceOutAnimationKey]) {
        [self.firstSelectedDayView.layer removeAllAnimations];
        self.isFirstSelectedDay = NO;
    }
    
    if (animation == [self.firstSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceInAnimationKey]) {
        [self.firstSelectedDayView.layer removeAllAnimations];
        self.isFirstSelectedDay = YES;
    }
    
    if (animation == [self.lastSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceOutAnimationKey]) {
        [self.lastSelectedDayView.layer removeAllAnimations];
        self.isLastSelectedDay = NO;
    }
    
    if (animation == [self.lastSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceInAnimationKey]) {
        [self.lastSelectedDayView.layer removeAllAnimations];
        self.isLastSelectedDay = YES;
    }
    if (self.completion) {
        self.completion(flag);
    }
}

@end
