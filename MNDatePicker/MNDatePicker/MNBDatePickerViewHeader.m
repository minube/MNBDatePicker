//
//  MNBDatePickerViewHeader.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerViewHeader.h"

static const CGFloat MNBDatePickerHeaderTextSize = 12.0f;

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

#pragma mark - Setters
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}
@end
