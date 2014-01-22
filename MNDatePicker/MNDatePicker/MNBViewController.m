//
//  MNBViewController.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBViewController.h"
#import "MNBDatePickerViewCell.h"

@interface MNBViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation MNBViewController

@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;

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
    
}

- (void)initCollectionView
{
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MNBDatePickerViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class])];
    [self.view addSubview:self.collectionView];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNBDatePickerViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNBDatePickerViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    cell.dayNumber = [NSString stringWithFormat:@"%d", indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
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
        offsetComponents.year = 1;
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