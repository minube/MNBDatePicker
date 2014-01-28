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
@property (nonatomic, assign) BOOL isFirstSelectedDay;
@end
