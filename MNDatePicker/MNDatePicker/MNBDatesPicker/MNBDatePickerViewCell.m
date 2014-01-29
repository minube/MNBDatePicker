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
    _isFirstSelectedDay = isFirstSelectedDay;
    self.firstSelectedDayView.alpha = isFirstSelectedDay ? 1.0f : 0.0f;
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated
{
    [self setIsFirstSelectedDay:isFirstSelectedDay animated:animated completion:nil];
}

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (isFirstSelectedDay) {
        [self startFirstSelectedDayBounceInAnimation];
    } else {
        [self startFirstSelectedDayBounceOutAnimation];
    }
}

#pragma mark - Animations
- (void)startFirstSelectedDayBounceInAnimation
{
    CGFloat initialScaleValue = 0.5f;
    self.dayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:self.dayLabel.font.pointSize];
    self.firstSelectedDayView.alpha = 0.0f;
    self.firstSelectedDayView.layer.transform = CATransform3DMakeScale(initialScaleValue, initialScaleValue, 1.0f);
    self.firstSelectedDayView.alpha = 1.0f;
    
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

- (void)startFirstSelectedDayBounceOutAnimation
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.delegate = self;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.1f],
                              [NSNumber numberWithFloat:0.0f], nil];
    bounceAnimation.duration = 0.1f;
    bounceAnimation.removedOnCompletion = NO;
    [self.firstSelectedDayView.layer addAnimation:bounceAnimation forKey:MNBDatePickerViewCellBounceOutAnimationKey];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    if (animation == [self.firstSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceOutAnimationKey]) {
        self.firstSelectedDayView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 1.0f);
        self.firstSelectedDayView.alpha = 0.0f;
        self.dayLabel.font = [UIFont fontWithName:@"Helvetica" size:self.dayLabel.font.pointSize];
        [self.firstSelectedDayView.layer removeAllAnimations];
    } if (animation == [self.firstSelectedDayView.layer animationForKey:MNBDatePickerViewCellBounceInAnimationKey]) {
        self.firstSelectedDayView.layer.transform = CATransform3DIdentity;
        [self.firstSelectedDayView.layer removeAllAnimations];
    }
}

@end
