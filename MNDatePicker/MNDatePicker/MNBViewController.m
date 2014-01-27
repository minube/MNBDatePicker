//
//  MNBViewController.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBViewController.h"
#import "MNBDatePickerViewCell.h"
#import "MNBDatePickerViewHeader.h"
#import "MNBDatePickerCollectionViewLayout.h"

static const NSUInteger MNBDatePickerDaysPerWeek = 7;
static const NSUInteger MNBDatePickerRowsPerMonth = 6; // This value is 6 to have same number of weeks(rows) per month
static const CGFloat MNBDatePickerHeaderHeight = 75.0f;
static const CGFloat MNBDatePickerItemsSpace = 2.0f;
static const NSUInteger MNBDatePickerYearOffset = 2;
static const CGFloat MNBDatePickerDefaultItemWidth = 42.0f;
static const NSUInteger MNBDatePickerCalendarsPerView = 2;
static const CGFloat MNBDatePickerSectionSpace = 14.0f;

@interface MNBViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MNBDatePickerCollectionViewLayoutDelegate>
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter;
@property (nonatomic, strong) NSDateFormatter *weekDaysFormatter;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *firstSelectedDate;
@property (nonatomic, strong) NSDate *lastSelectedDate;
@property (nonatomic ,strong) NSArray *selectedIndexPaths;
@end

@implementation MNBViewController

@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;

- (instancetype)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _sameNumberOfWeeksPerMonth = YES;
    _showDaysOnlyBelongsToMonth = YES;
    _currentSection = 0;
}

- (void)initCollectionView
{
    MNBDatePickerCollectionViewLayout *customLayout = [[MNBDatePickerCollectionViewLayout alloc] init];
    customLayout.delegate = self;
    customLayout.itemsSpace = MNBDatePickerItemsSpace;
    customLayout.headerHeight = MNBDatePickerHeaderHeight;
    CGFloat sectionSpace = 0.0f;
    if (MNBDatePickerCalendarsPerView > 1) {
        sectionSpace = MNBDatePickerSectionSpace;
    }
    customLayout.sectionsSpace = sectionSpace;
    CGFloat totalAmountOfVisibleSectionSpace = (MNBDatePickerCalendarsPerView - 1) * sectionSpace;
    CGFloat totalAmountOfVisibleCalendars = ((MNBDatePickerDefaultItemWidth * MNBDatePickerDaysPerWeek) + ((MNBDatePickerDaysPerWeek - 1) * MNBDatePickerItemsSpace)) * MNBDatePickerCalendarsPerView;
    CGFloat collectionViewWidth = totalAmountOfVisibleCalendars + totalAmountOfVisibleSectionSpace;
    CGFloat collectionViewHeight = MNBDatePickerHeaderHeight + (MNBDatePickerDefaultItemWidth * MNBDatePickerRowsPerMonth) + ((MNBDatePickerRowsPerMonth - 1) * MNBDatePickerItemsSpace);
    UIView *collectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, collectionViewWidth, collectionViewHeight)];
    collectionViewContainer.clipsToBounds = YES;
    collectionViewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionViewContainer];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, collectionViewWidth + MNBDatePickerSectionSpace, collectionViewHeight) collectionViewLayout:customLayout];
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, MNBDatePickerSectionSpace);
    [self.collectionView registerClass:[MNBDatePickerViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class])];
    [self.collectionView registerClass:[MNBDatePickerViewHeader class] forSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withReuseIdentifier:NSStringFromClass([MNBDatePickerViewHeader class])];
    [collectionViewContainer addSubview:self.collectionView];
}

- (void)initArrows
{
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:20];
    nextButton.backgroundColor = [UIColor grayColor];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [nextButton addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:20];
    backButton.backgroundColor = [UIColor grayColor];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(backPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
    
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [self initArrows];
}

#pragma mark - UICollectionViewDelegate
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == MNBDatePickerCollectionViewLayoutSectionHeaderKind) {
        MNBDatePickerViewHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withReuseIdentifier:NSStringFromClass([MNBDatePickerViewHeader class]) forIndexPath:indexPath];
        
        headerView.title = [self.headerDateFormatter stringFromDate:[self firstDayOfMonthForSection:indexPath.section]].uppercaseString;
        headerView.weekDays = [self daysOfTheWeek];
        return headerView;
    }
    
    return nil;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    NSDate *firstDayOfMonth = [self firstDayOfMonthForSection:indexPath.section];
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstDayOfMonthComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstDayOfMonth];
    
    if ((cellDateComponents.month == firstDayOfMonthComponents.month) || !self.showDaysOnlyBelongsToMonth) {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDate = [self dateForCellAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:self.lastDate options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger weeksPerMonth = MNBDatePickerRowsPerMonth;
    if (!self.sameNumberOfWeeksPerMonth) {
        NSDate *firstDayOfMonth = [self firstDayOfMonthForSection:section];
        NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstDayOfMonth];
        weeksPerMonth = rangeOfWeeks.length;
    }
    
    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return (weeksPerMonth * MNBDatePickerDaysPerWeek);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNBDatePickerViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class]) forIndexPath:indexPath];
    
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    NSDate *firstDayOfMonth = [self firstDayOfMonthForSection:indexPath.section];
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstDayOfMonthComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstDayOfMonth];
    
    NSString *cellTitleString = @"";
    
    BOOL isSelected = NO;
    if ((cellDateComponents.month == firstDayOfMonthComponents.month) || !self.showDaysOnlyBelongsToMonth) {
        cellTitleString = [NSString stringWithFormat:@"%@", @(cellDateComponents.day)];
        isSelected = [self isSelectedIndexPath:indexPath];
    }
    cell.dayNumber = cellTitleString;
    cell.selected = isSelected;
    return cell;
}

#pragma mark - MNBDatePickerCollectionViewLayoutDelegate
- (CGSize)sizeForItemsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout
{
//    CGFloat totalItemsSpace = (MNBDatePickerRowsPerMonth - 1) * MNBDatePickerItemsSpace;
//    CGFloat itemHeight = floorf((CGRectGetHeight(self.collectionView.bounds) - MNBDatePickerHeaderHeight - totalItemsSpace) / MNBDatePickerRowsPerMonth);
    return CGSizeMake(MNBDatePickerDefaultItemWidth, MNBDatePickerDefaultItemWidth);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentSection = [self firstVisibleIndexPath].section;
}

#pragma mark - Collection View / Calendar Methods
- (NSDate *)firstDayOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (NSArray *)daysOfTheWeek
{
    // adjust array depending on which weekday should be first
    NSArray *weekdays = [self.weekDaysFormatter shortWeekdaySymbols];
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }
    return weekdays;
}

- (BOOL)isSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    BOOL isSelected = NO;
    if (self.selectedIndexPaths) {
        for (NSIndexPath *indexPath in self.selectedIndexPaths) {
            NSComparisonResult comparisonResult = [indexPath compare:selectedIndexPath];
            if (comparisonResult == NSOrderedSame) {
                isSelected = YES;
            }
        }
    }
    
    return isSelected;
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    
    return [refDate isEqualToDate:clampedDate];
}

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:date options:0].month;
}

- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstOfMonth = [self firstDayOfMonthForSection:section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    
    
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    NSInteger item = (dateComponents.day - firstOfMonthComponents.day) - (1 - ordinalityOfFirstDay);
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstDayOfMonthForSection:indexPath.section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}

- (MNBDatePickerViewCell *)cellForItemAtDate:(NSDate *)date
{
    return (MNBDatePickerViewCell *)[self.collectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}

- (NSIndexPath *)firstVisibleIndexPath
{
    NSArray *visibleIndexPaths = self.collectionView.indexPathsForVisibleItems;
    NSIndexPath *firstVisibleIndexPath = visibleIndexPaths.lastObject;
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if ([firstVisibleIndexPath compare:indexPath] == NSOrderedDescending) {
            firstVisibleIndexPath = indexPath;
        }
    }
    
    return firstVisibleIndexPath;
}

#pragma mark - IBActions
- (void)nextPage:(UIButton *)button
{
    if (self.currentSection < self.collectionView.numberOfSections - 1) {
        self.currentSection += MNBDatePickerCalendarsPerView;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.currentSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (void)backPage:(UIButton *)button
{
    if (self.currentSection > 0) {
        self.currentSection -= MNBDatePickerCalendarsPerView;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.currentSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

#pragma mark - Rotation Handling
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Setters
- (void)setFirstDate:(NSDate *)firstDate
{
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:firstDate];
    _firstDate = [self.calendar dateFromComponents:components];
}

- (void)setLastDate:(NSDate *)lastDate
{
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:lastDate];
    NSDate *firstDayOfMonth = [self.calendar dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstDayOfMonth options:0];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (_selectedDate != selectedDate) {
        _selectedDate = selectedDate;
        NSArray *newSelectedIndexPaths = nil;
        NSArray *selectedIndexPaths = nil;
        if (!self.firstSelectedDate) {
            self.firstSelectedDate = _selectedDate;
            newSelectedIndexPaths = [self selectedIndexPathsBetweenFirstDate:self.firstSelectedDate lastDate:nil];
            selectedIndexPaths = newSelectedIndexPaths;
        } else {
            NSComparisonResult comparison = [self.firstSelectedDate compare:_selectedDate];
            switch (comparison) {
                case NSOrderedSame: // selected = firstdate
                    self.firstSelectedDate = nil;
                    self.lastSelectedDate = nil;
                    selectedIndexPaths  = [NSArray arrayWithObject:[self indexPathForCellAtDate:_selectedDate]];
                    break;
                case NSOrderedDescending: // selected < firstdate
                    if (self.lastSelectedDate) {
                        selectedIndexPaths = [self selectedIndexPathsBetweenFirstDate:_selectedDate lastDate:self.lastSelectedDate];
                        self.firstSelectedDate = nil;
                        self.lastSelectedDate = nil;
                    } else {
                        selectedIndexPaths = [self selectedIndexPathsBetweenFirstDate:_selectedDate lastDate:self.firstSelectedDate];
                        self.firstSelectedDate = nil;
                    }
                    break;
                case NSOrderedAscending: // selected > firstdate
                    self.lastSelectedDate = _selectedDate;
                    newSelectedIndexPaths = [self selectedIndexPathsBetweenFirstDate:self.firstSelectedDate lastDate:self.lastSelectedDate];
                    selectedIndexPaths = newSelectedIndexPaths;
                    break;
            }
        }
        
        NSArray *indexPathsToReload = [self indexPathToReloadForOldIndexPaths:self.selectedIndexPaths newIndexPaths:selectedIndexPaths];
        self.selectedIndexPaths = newSelectedIndexPaths;
        [self.collectionView reloadItemsAtIndexPaths:indexPathsToReload];
    }
}

- (NSArray *)indexPathToReloadForOldIndexPaths:(NSArray *)oldIndexPaths newIndexPaths:(NSArray *)newIndexPaths
{
    NSArray *indexPathsToReload = nil;
    if (oldIndexPaths) {
        if (newIndexPaths) {
            // smaller firstIndexPath to relod
            NSIndexPath *firstOldSelectedIndexPath = [oldIndexPaths objectAtIndex:0];
            NSIndexPath *firstNewSelectedIndexPath = [newIndexPaths objectAtIndex:0];
            NSIndexPath *firstIndexPathToReload = nil;
            NSComparisonResult comparisonResult = [firstOldSelectedIndexPath compare:firstNewSelectedIndexPath];
            switch (comparisonResult) {
                case NSOrderedSame:
                    firstIndexPathToReload = firstOldSelectedIndexPath;
                    break;
                case NSOrderedAscending:
                    firstIndexPathToReload = firstOldSelectedIndexPath;
                    break;
                case NSOrderedDescending:
                    firstIndexPathToReload = firstNewSelectedIndexPath;
                    break;
            }
            
            // bigger lastIndexPath to relod
            NSIndexPath *lastOldSelectedIndexPath = oldIndexPaths.lastObject;
            NSIndexPath *lastNewSelectedIndexPath = newIndexPaths.lastObject;
            NSIndexPath *lastIndexPathToReload = nil;
            comparisonResult = [lastOldSelectedIndexPath compare:lastNewSelectedIndexPath];
            switch (comparisonResult) {
                case NSOrderedSame:
                    lastIndexPathToReload = lastOldSelectedIndexPath;
                    break;
                case NSOrderedAscending:
                    lastIndexPathToReload = lastNewSelectedIndexPath;
                    break;
                case NSOrderedDescending:
                    lastIndexPathToReload = lastOldSelectedIndexPath;
                    break;
            }
            
            indexPathsToReload = [self indexPathsBetweenFirstIndexPath:firstIndexPathToReload lastIndexPath:lastIndexPathToReload];
        } else {
            indexPathsToReload = [NSArray arrayWithArray:oldIndexPaths];
        }
    } else {
        if (newIndexPaths) {
            indexPathsToReload = [NSArray arrayWithArray:newIndexPaths];
        }
    }
    
    return indexPathsToReload;
}

- (void)reloadCellsBeteweenFirstSelectedDate:(NSDate *)firstSelectedDate lastSelectedDate:(NSDate *)lastSelectedDate
{
    NSArray *selectedIndexPaths = nil;
    NSArray *indexPathsToReload = nil;
    
    selectedIndexPaths = [self selectedIndexPathsBetweenFirstDate:firstSelectedDate lastDate:lastSelectedDate];
    NSLog(@"%@", selectedIndexPaths);
    if (self.selectedIndexPaths) {
        if (selectedIndexPaths) {
            // smaller firstIndexPath to relod
            NSIndexPath *firstOldSelectedIndexPath = [self.selectedIndexPaths objectAtIndex:0];
            NSIndexPath *firstNewSelectedIndexPath = [selectedIndexPaths objectAtIndex:0];
            NSIndexPath *firstIndexPathToReload = nil;
            NSComparisonResult comparisonResult = [firstOldSelectedIndexPath compare:firstNewSelectedIndexPath];
            switch (comparisonResult) {
                case NSOrderedSame:
                    firstIndexPathToReload = firstOldSelectedIndexPath;
                    break;
                case NSOrderedAscending:
                    firstIndexPathToReload = firstOldSelectedIndexPath;
                    break;
                case NSOrderedDescending:
                    firstIndexPathToReload = firstNewSelectedIndexPath;
                    break;
            }
            
            // bigger lastIndexPath to relod
            NSIndexPath *lastOldSelectedIndexPath = self.selectedIndexPaths.lastObject;
            NSIndexPath *lastNewSelectedIndexPath = selectedIndexPaths.lastObject;
            NSIndexPath *lastIndexPathToReload = nil;
            comparisonResult = [lastOldSelectedIndexPath compare:lastNewSelectedIndexPath];
            switch (comparisonResult) {
                case NSOrderedSame:
                    lastIndexPathToReload = lastOldSelectedIndexPath;
                    break;
                case NSOrderedAscending:
                    lastIndexPathToReload = lastNewSelectedIndexPath;
                    break;
                case NSOrderedDescending:
                    lastIndexPathToReload = lastOldSelectedIndexPath;
                    break;
            }
            
            indexPathsToReload = [self indexPathsBetweenFirstIndexPath:firstIndexPathToReload lastIndexPath:lastIndexPathToReload];
            self.selectedIndexPaths = selectedIndexPaths;
        } else {
            indexPathsToReload = [NSArray arrayWithArray:self.selectedIndexPaths];
            self.selectedIndexPaths = nil;
        }
    } else {
        if (selectedIndexPaths) {
            indexPathsToReload = selectedIndexPaths;
            self.selectedIndexPaths = selectedIndexPaths;
        }
    }
    
    [self.collectionView reloadItemsAtIndexPaths:indexPathsToReload];
}

- (NSArray *)selectedIndexPathsBetweenFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate
{
    NSArray *selectedIndexPaths = nil;
    
    if (firstDate) {
        NSIndexPath *firstDateIndexPath = [self indexPathForCellAtDate:firstDate];
        if (lastDate) {
            NSIndexPath *lastDateIndexPath = [self indexPathForCellAtDate:lastDate];
            selectedIndexPaths = [self indexPathsBetweenFirstIndexPath:firstDateIndexPath lastIndexPath:lastDateIndexPath];
        } else {
            selectedIndexPaths = [NSArray arrayWithObject:firstDateIndexPath];
        }
    }
    
    return selectedIndexPaths;
}

- (NSArray *)indexPathsBetweenFirstIndexPath:(NSIndexPath *)firstIndexPath lastIndexPath:(NSIndexPath *)lastIndexPath
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSIndexPath *actualFirstIndexPath;
    NSIndexPath *actualLastIndexPath;
    
    NSComparisonResult comparisonResult = [firstIndexPath compare:lastIndexPath];
    switch (comparisonResult) {
        case NSOrderedSame:
            return [NSArray arrayWithObjects:firstIndexPath, nil];
            break;
        case NSOrderedAscending:
            actualFirstIndexPath = firstIndexPath;
            actualLastIndexPath = lastIndexPath;
            break;
        case NSOrderedDescending:
            actualFirstIndexPath = lastIndexPath;
            actualLastIndexPath = firstIndexPath;
            break;
    }
    
    if (actualFirstIndexPath.section == actualLastIndexPath.section) {
        for (NSInteger item = actualFirstIndexPath.item; item <= actualLastIndexPath.item; item++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:actualFirstIndexPath.section]];
        }
    } else {
        for (NSInteger section = actualFirstIndexPath.section; section <= actualLastIndexPath.section; section++) {
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            if (section == actualFirstIndexPath.section) {
                for (NSInteger item = actualFirstIndexPath.item; item < numberOfItemsInSection; item++) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:section]];
                }
            } else if (section != actualFirstIndexPath.section && section != actualLastIndexPath.section) {
                for (NSInteger item = 0; item < numberOfItemsInSection; item++) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:section]];
                }
            } else {
                for (NSInteger item = 0; item <= actualLastIndexPath.item; item++) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:section]];
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

#pragma mark - Getters
- (NSDateFormatter *)headerDateFormatter
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        _headerDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
    }
    return _headerDateFormatter;
}

- (NSDateFormatter *)weekDaysFormatter
{
    if (!_weekDaysFormatter) {
        _weekDaysFormatter = [[NSDateFormatter alloc] init];
        _weekDaysFormatter.calendar = self.calendar;
        _weekDaysFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL yyyy" options:0 locale:[NSLocale currentLocale]];
    }
    
    return _weekDaysFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        [self setFirstDate:[NSDate date]];
    }
    
    return _firstDate;
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = MNBDatePickerYearOffset;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDate options:0]];
    }
    return _lastDate;
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
