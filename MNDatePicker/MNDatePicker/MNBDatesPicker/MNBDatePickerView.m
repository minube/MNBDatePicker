//
//  MNBDatePickerView.m
//  MNDatePicker
//
//  Created by Ruben on 27/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBDatePickerView.h"
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

@interface MNBDatePickerView () <UICollectionViewDelegate, UICollectionViewDataSource, MNBDatePickerCollectionViewLayoutDelegate>
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter;
@property (nonatomic, strong) NSDateFormatter *weekDaysFormatter;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic ,strong) NSArray *selectedIndexPaths;
@property (nonatomic, strong) NSDate *firstSelectedDate;
@property (nonatomic, strong) NSDate *lastSelectedDate;
@property (nonatomic, strong) NSDate *today;
@end

@implementation MNBDatePickerView

@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    
    [self setUpCollectionView];
    [self setUpArrows];
}

- (void)setUpCollectionView
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
    UIView *collectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
    collectionViewContainer.clipsToBounds = YES;
    collectionViewContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionViewContainer];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width + MNBDatePickerSectionSpace, self.bounds.size.height) collectionViewLayout:customLayout];
    self.collectionView.backgroundColor = colorWithRGBA(15, 20, 28, 1);
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, MNBDatePickerSectionSpace);
    [self.collectionView registerClass:[MNBDatePickerViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class])];
    [self.collectionView registerClass:[MNBDatePickerViewHeader class] forSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withReuseIdentifier:NSStringFromClass([MNBDatePickerViewHeader class])];
    [collectionViewContainer addSubview:self.collectionView];
}

- (void)setUpArrows
{
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [nextButton addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-25.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(backPage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:25.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
    
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
    
    if ([cellDate compare:self.today] == NSOrderedAscending) {
        return NO;
    }
    
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
    BOOL isFirstSelectedDate = NO;
    BOOL isLastSelectedDate = NO;
    BOOL isDisableDate = NO;
    
    if ((cellDateComponents.month == firstDayOfMonthComponents.month) || !self.showDaysOnlyBelongsToMonth) {
        cellTitleString = [NSString stringWithFormat:@"%@", @(cellDateComponents.day)];
        
        if ([cellDate compare:self.today] == NSOrderedAscending) {
            isDisableDate = YES;
        }
        
        if (!isDisableDate) {
            if (self.firstSelectedDate && self.lastSelectedDate && [self.firstSelectedDate compare:cellDate] == NSOrderedAscending && [self.lastSelectedDate compare:cellDate] == NSOrderedDescending) {
                isSelected = YES;
            }
            if (self.firstSelectedDate && [self.firstSelectedDate compare:cellDate] == NSOrderedSame) {
                isFirstSelectedDate = YES;
            } else if (self.lastSelectedDate && [self.lastSelectedDate compare:cellDate] == NSOrderedSame) {
                isLastSelectedDate = YES;
            }
        }
    }
    
    cell.dayNumber = cellTitleString;
    cell.isFirstSelectedDay = isFirstSelectedDate;
    cell.isSelectedDay = isSelected;
    cell.isLastSelectedDay = isLastSelectedDate;
    cell.isDisableDay = isDisableDate;
    return cell;
}

#pragma mark - MNBDatePickerCollectionViewLayoutDelegate
- (CGSize)sizeForItemsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout
{
    CGFloat totalAmountOfSectionsSpace = (MNBDatePickerCalendarsPerView - 1) * MNBDatePickerSectionSpace;
    CGFloat totalAmountOfItemsSpace = (MNBDatePickerDaysPerWeek - 1) * MNBDatePickerItemsSpace * MNBDatePickerCalendarsPerView;
    CGFloat itemWidth = (self.bounds.size.width - totalAmountOfSectionsSpace - totalAmountOfItemsSpace) / (MNBDatePickerDaysPerWeek * MNBDatePickerCalendarsPerView);
    CGFloat totalVerticalItemsSpace = (MNBDatePickerRowsPerMonth - 1) * MNBDatePickerItemsSpace;
    CGFloat itemHeight = (self.bounds.size.height - MNBDatePickerHeaderHeight - totalVerticalItemsSpace) / MNBDatePickerRowsPerMonth;
    return CGSizeMake(itemWidth, itemHeight);
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
    if (self.selectedIndexPaths) {
        for (NSIndexPath *indexPath in self.selectedIndexPaths) {
            NSComparisonResult comparisonResult = [indexPath compare:selectedIndexPath];
            if (comparisonResult == NSOrderedSame) {
                return YES;
            }
        }
    }
    
    return NO;
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

- (NSDate *)addDays:(NSInteger)numberOfDays toDate:(NSDate *)date
{
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:numberOfDays];
    
    // Retrieve date with increased days count
    return [self.calendar dateByAddingComponents:dateComponents toDate:date options:0];
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
        if (!self.firstSelectedDate) {
            self.firstSelectedDate = _selectedDate;
            MNBDatePickerViewCell *cell = [self cellForItemAtDate:self.firstSelectedDate];
            [cell setIsFirstSelectedDay:YES animated:YES];
            if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidChangeSelectionWithFirstSelectedDate:lastSelectedDate:)]) {
                [self.delegate mnbDatePickerDidChangeSelectionWithFirstSelectedDate:self.firstSelectedDate lastSelectedDate:self.lastSelectedDate];
            }
        } else {
            NSComparisonResult comparison = [self.firstSelectedDate compare:_selectedDate];
            switch (comparison) {
                case NSOrderedSame: // selected = firstdate
                {
                    if (self.lastSelectedDate) {
                        self.firstSelectedDate = nil;
                        self.lastSelectedDate = nil;
                        [self.collectionView reloadData];
                        if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidCancelSelection)]) {
                            [self.delegate mnbDatePickerDidCancelSelection];
                        }
                    } else {
                        MNBDatePickerViewCell *cell = [self cellForItemAtDate:self.firstSelectedDate];
                        [cell setIsFirstSelectedDay:NO animated:YES];
                        self.firstSelectedDate = nil;
                        if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidCancelSelection)]) {
                            [self.delegate mnbDatePickerDidCancelSelection];
                        }
                    }
                }
                    break;
                case NSOrderedDescending: // selected < firstdate
                    if (self.lastSelectedDate) {
                        self.firstSelectedDate = nil;
                        self.lastSelectedDate = nil;
                        [self.collectionView reloadData];
                        if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidCancelSelection)]) {
                            [self.delegate mnbDatePickerDidCancelSelection];
                        }
                    } else {
                        MNBDatePickerViewCell *cell = [self cellForItemAtDate:self.firstSelectedDate];
                        [cell setIsFirstSelectedDay:NO animated:YES];
                        self.firstSelectedDate = nil;
                        if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidCancelSelection)]) {
                            [self.delegate mnbDatePickerDidCancelSelection];
                        }
                    }
                    break;
                case NSOrderedAscending: // selected > firstdate
                    self.lastSelectedDate = _selectedDate;
                    [self.collectionView reloadData];
                    if ([self.delegate respondsToSelector:@selector(mnbDatePickerDidChangeSelectionWithFirstSelectedDate:lastSelectedDate:)]) {
                        [self.delegate mnbDatePickerDidChangeSelectionWithFirstSelectedDate:self.firstSelectedDate lastSelectedDate:self.lastSelectedDate];
                    }
                    break;
            }
        }
    }
}

- (void)setFirstPreSelectedDate:(NSDate *)firstPreSelectedDate
{
    if (firstPreSelectedDate) {
        firstPreSelectedDate = [self clampDate:firstPreSelectedDate toComponents:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)];
        _firstPreSelectedDate = firstPreSelectedDate;
        if (self.firstSelectedDate && [_firstPreSelectedDate compare:self.firstSelectedDate] != NSOrderedSame) {
            self.firstSelectedDate = _firstPreSelectedDate;
            if ([self.firstSelectedDate compare:self.lastSelectedDate] != NSOrderedAscending) {
                self.lastSelectedDate = nil;
            }
            [self.collectionView reloadData];
        } else if (!self.firstSelectedDate) {
            self.firstSelectedDate = _firstPreSelectedDate;
            [self.collectionView reloadData];
        }
    } else {
        _firstPreSelectedDate = nil;
        _lastPreSelectedDate = nil;
        self.firstSelectedDate = nil;
        self.lastSelectedDate = nil;
        [self.collectionView reloadData];
    }
}

- (void)setLastPreSelectedDate:(NSDate *)lastPreSelectedDate
{
    if (lastPreSelectedDate) {
        lastPreSelectedDate = [self clampDate:lastPreSelectedDate toComponents:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)];
        _lastPreSelectedDate = lastPreSelectedDate;
        if (self.lastSelectedDate &&  [_lastPreSelectedDate compare:self.lastSelectedDate] != NSOrderedSame) {
            // Protection against invalid last choosen dates
            if (self.firstSelectedDate && [self.firstSelectedDate compare:_lastPreSelectedDate] == NSOrderedAscending) {
                self.lastSelectedDate = _lastPreSelectedDate;
                [self.collectionView reloadData];
            }
        } else if (!self.lastSelectedDate) {
            self.lastSelectedDate = _lastPreSelectedDate;
            [self.collectionView reloadData];
        }
    } else {
        _lastPreSelectedDate = nil;
        self.lastSelectedDate = nil;
        [self.collectionView reloadData];
    }
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

- (NSDate *)today
{
    if (!_today) {
        _today = [self.calendar dateFromComponents:[self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]]];
    }
    return _today;
}

@end
