//
//  MNBDatePickerCollectionViewLayout.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerCollectionViewLayout.h"

static NSString * const MNBDatePickerCollectionViewLayoutCellKind = @"MNBDatePickerViewCell";
NSString * const MNBDatePickerCollectionViewLayoutSectionHeaderKind = @"MNBDatePickerViewSectionHeader";
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
    self.headerHeight = 50.0f;
}

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *sectionHeaderLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionsCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        // Attributes for headers
        UICollectionViewLayoutAttributes *sectionHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withIndexPath:indexPath];
        sectionHeaderAttributes.frame = [self frameForSectionHeaderAtSection:section];
        sectionHeaderLayoutInfo[indexPath] = sectionHeaderAttributes;
        
        // Attributes for items
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item <itemsCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[MNBDatePickerCollectionViewLayoutCellKind] = cellLayoutInfo;
    newLayoutInfo[MNBDatePickerCollectionViewLayoutSectionHeaderKind] = sectionHeaderLayoutInfo;
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[MNBDatePickerCollectionViewLayoutSectionHeaderKind][indexPath];
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
- (CGRect)frameForSectionHeaderAtSection:(NSInteger)section
{
    CGFloat originX = 0.0f;
    if (section) {
        for (NSInteger currentSection = 0; currentSection < section; currentSection++) {
            originX += [self widthForSection:currentSection] + self.sectionsSpace;
        }
    }
    CGFloat originY = 0.0f;
    return CGRectMake(originX, originY, [self widthForSection:section], self.headerHeight);
}

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
    CGFloat originY = floorf((self.itemSize.height + self.itemsSpace) * row) + self.headerHeight;
    
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

#pragma mark - Setters
- (void)setNumberOfColumns:(NSUInteger)numberOfColumns
{
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        [self invalidateLayout];
    }
}

- (void)setItemsSpace:(CGFloat)itemsSpace
{
    if (_itemsSpace != itemsSpace) {
        _itemsSpace = itemsSpace;
        [self invalidateLayout];
    }
}

- (void)setSectionsSpace:(CGFloat)sectionsSpace
{
    if (_sectionsSpace != sectionsSpace) {
        _sectionsSpace = sectionsSpace;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

@end
