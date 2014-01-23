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
static const CGFloat MNBDatePickerHeaderHeight = 100.0f;
static const CGFloat MNBDatePickerItemsSpace = 2.0f;
static const NSUInteger MNBDatePickerYearOffset = 2;

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
}

- (void)initCollectionView
{
    MNBDatePickerCollectionViewLayout *customLayout = [[MNBDatePickerCollectionViewLayout alloc] init];
    customLayout.delegate = self;
    customLayout.itemsSpace = MNBDatePickerItemsSpace;
    customLayout.headerHeight = MNBDatePickerHeaderHeight;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:customLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MNBDatePickerViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class])];
    [self.collectionView registerClass:[MNBDatePickerViewHeader class] forSupplementaryViewOfKind:MNBDatePickerCollectionViewLayoutSectionHeaderKind withReuseIdentifier:NSStringFromClass([MNBDatePickerViewHeader class])];
    [self.view addSubview:self.collectionView];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
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
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:cellDate];
    NSString *cellTitleString = [NSString stringWithFormat:@"%@, %@", @(cellDateComponents.day), @(cellDateComponents.month)];
    cell.dayNumber = cellTitleString;
    
    return cell;
}

#pragma mark - MNBDatePickerCollectionViewLayoutDelegate
- (CGSize)sizeForItemsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout
{
    CGFloat totalItemsSpace = (MNBDatePickerRowsPerMonth - 1) * MNBDatePickerItemsSpace;
    CGFloat itemHeight = floorf((CGRectGetHeight(self.collectionView.bounds) - MNBDatePickerHeaderHeight - totalItemsSpace) / MNBDatePickerRowsPerMonth);
    return CGSizeMake(itemHeight, itemHeight);
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
