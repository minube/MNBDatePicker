//
//  MNBDatePickerCollectionViewLayout.h
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNBDatePickerCollectionViewLayoutDelegate <NSObject>
@optional
- (CGSize)sizeForItemsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout;
@end

@interface MNBDatePickerCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, assign) NSUInteger numberOfColumns; // number of columms per section
@property (nonatomic, assign) CGFloat itemsSpace; // Space between items
@property (nonatomic, assign) CGFloat sectionsSpace; // Space between sections
@property (nonatomic, assign) CGFloat headerHeight; // Height for the headers displayed above every section
@property (nonatomic, assign) id<MNBDatePickerCollectionViewLayoutDelegate> delegate;
@end
