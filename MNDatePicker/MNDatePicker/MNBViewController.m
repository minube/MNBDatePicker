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
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, collectionViewWidth , collectionViewHeight) collectionViewLayout:customLayout];
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MNBDatePickerViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class])];
    [self.collectionView registerClass:[MNBDatePickerViewHeader class] forSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withReuseIdentifier:NSStringFromClass([MNBDatePickerViewHeader class])];
    [self.view addSubview:self.collectionView];
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
    if ((cellDateComponents.month == firstDayOfMonthComponents.month) || !self.showDaysOnlyBelongsToMonth) {
        cellTitleString = [NSString stringWithFormat:@"%@", @(cellDateComponents.day)];
    }
    cell.dayNumber = cellTitleString;
    
    return cell;
}

#pragma mark - MNBDatePickerCollectionViewLayoutDelegate
- (CGSize)sizeForItemsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout
{
//    CGFloat totalItemsSpace = (MNBDatePickerRowsPerMonth - 1) * MNBDatePickerItemsSpace;
//    CGFloat itemHeight = floorf((CGRectGetHeight(self.collectionView.bounds) - MNBDatePickerHeaderHeight - totalItemsSpace) / MNBDatePickerRowsPerMonth);
    return CGSizeMake(MNBDatePickerDefaultItemWidth, MNBDatePickerDefaultItemWidth);
}

#pragma mark - Collection View / Calendar Methods
- (NSDate *)firstDayOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstDayOfMonthForSection:indexPath.section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
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

#pragma mark - IBActions
- (void)nextPage:(UIButton *)button
{
    if (self.collectionView.contentOffset.x <= self.collectionView.contentSize.width) {
        CGRect nextFrame = CGRectZero;
        nextFrame.origin.x = self.collectionView.contentOffset.x + self.collectionView.frame.size.width;
        nextFrame.origin.y = 0;
        nextFrame.size = self.collectionView.frame.size;
        [self.collectionView scrollRectToVisible:nextFrame animated:YES];
    }
}

- (void)backPage:(UIButton *)button
{
    if (self.collectionView.contentOffset.x >= self.collectionView.frame.size.width) {
        CGRect backFrame = CGRectZero;
        backFrame.origin.x = self.collectionView.contentOffset.x - self.collectionView.frame.size.width;
        backFrame.origin.y = 0;
        backFrame.size = self.collectionView.frame.size;
        [self.collectionView scrollRectToVisible:backFrame animated:YES];
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
