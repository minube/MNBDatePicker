//
//  MNBViewController.m
//  MNDatePicker
//
//  Created by Ruben on 22/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBViewController.h"
#import "MNBDatePickerView.h"

@interface MNBViewController ()
@property (nonatomic, strong) MNBDatePickerView *datePickerView;
@end

@implementation MNBViewController

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
    self.datePickerView = [[MNBDatePickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 636, 336)];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.datePickerView];
}

#pragma mark - Rotation Handling
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Call MNBDatePickerView method to reload layout - internally self.collectionView invalidatelayout
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
