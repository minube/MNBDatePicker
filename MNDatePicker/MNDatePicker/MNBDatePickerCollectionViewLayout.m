//
//  MNBDatePickerCollectionViewLayout.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerCollectionViewLayout.h"

static NSString * const MNBDatePickerCollectionViewLayoutCellKind = @"MNBDatePickerViewCell";
static const NSUInteger MNBDatePickerCollectionViewLayoutDefaultNumberOfColumns = 7;

@interface MNBDatePickerCollectionViewLayout ()
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation MNBDatePickerCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    // Default values
    self.numberOfColumns = MNBDatePickerCollectionViewLayoutDefaultNumberOfColumns;
    self.itemsSpace = 2.0f;
    self.sectionsSpace = 14.0f;
}

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item <itemsCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[MNBDatePickerCollectionViewLayoutCellKind] = cellLayoutInfo;
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[MNBDatePickerCollectionViewLayoutCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    NSInteger contentSizeWidth = 0;
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionsCount; section++) {
        contentSizeWidth += [self widthForSection:section];
    }
    
    CGFloat totalSectionsSpace = (sectionsCount - 1) * self.sectionsSpace;
    
    return CGSizeMake(contentSizeWidth + totalSectionsSpace, self.collectionView.bounds.size.height);
}

#pragma mark - Layout Calculations
- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = (indexPath.item / self.numberOfColumns);
    NSInteger column = indexPath.item - (row * self.numberOfColumns);
    
    CGFloat xOffset = 0.0f;
    if (indexPath.section) {
        for (NSInteger section = 0; section < indexPath.section; section++) {
            xOffset += [self widthForSection:section] + self.sectionsSpace;
        }
    }
    CGFloat originX = floorf((self.itemSize.width + self.itemsSpace) * column) + xOffset;
    CGFloat originY = floor((self.itemSize.height + self.itemsSpace) * row);
    
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

- (CGFloat)widthForSection:(NSInteger)section
{
    NSInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
    NSUInteger maximunNumberOfColumnsForSection = self.numberOfColumns;
    if (itemsInSection < self.numberOfColumns) {
        maximunNumberOfColumnsForSection = itemsInSection;
    }
    
    return (maximunNumberOfColumnsForSection * self.itemSize.width) + ((maximunNumberOfColumnsForSection - 1) * self.itemsSpace);
}

#pragma mark - Getters
- (CGSize)itemSize
{
    CGSize itemSize = CGSizeZero;
    // First ask to the delegate for custom size
    if ([self.delegate respondsToSelector:@selector(sizeForItemsForCollectionView:layout:)]) {
        itemSize = [self.delegate sizeForItemsForCollectionView:self.collectionView layout:self];
    } else { // Default
        CGFloat totalSpace = (self.numberOfColumns - 1) * self.itemsSpace;
        CGFloat width = floorf((CGRectGetWidth(self.collectionView.bounds) - totalSpace) / self.numberOfColumns);
        itemSize = CGSizeMake(width, width);
    }
    
    return itemSize;
}

@end
