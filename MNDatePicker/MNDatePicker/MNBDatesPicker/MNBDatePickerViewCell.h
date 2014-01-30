//
//  MNBDatePickerViewCell.h
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNBDatePickerViewCell : UICollectionViewCell
@property (nonatomic, strong) NSString *dayNumber;
@property (nonatomic, assign) BOOL isSelectedDay;
@property (nonatomic, assign) BOOL isFirstSelectedDay;
@property (nonatomic, assign) BOOL isLastSelectedDay;

- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated;
- (void)setIsFirstSelectedDay:(BOOL)isFirstSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)setIsLastSelectedDay:(BOOL)isLastSelectedDay animated:(BOOL)animated;
- (void)setIsLastSelectedDay:(BOOL)isLastSelectedDay animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
@end
