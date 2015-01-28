//
//  SAPageControl.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "SAPageControl.h"
#import "FavStocksCollectionViewController.h"
#import "PortfilioTableViewController.h"
#import "HistoryTableViewController.h"

@implementation SAPageControl


- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (SAPageControl *)sharedInstance
{
    static SAPageControl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Page View Methods

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index withViewController:(UIViewController*)viewController
{
    
    // Create a new view controller and pass suitable data.
    UIViewController *vc = nil;
    
    switch (index) {
        case 0:
            vc = [viewController.storyboard instantiateViewControllerWithIdentifier:@"FavStocksCollectionViewController"];
            break;
            
        case 1:
            vc = [viewController.storyboard instantiateViewControllerWithIdentifier:@"PortfilioTableViewController"];
            break;
            
        case 2:
            vc = [viewController.storyboard instantiateViewControllerWithIdentifier:@"HistoryTableViewController"];
            break;
            
        default:
            //issue. bug. if gets here
            break;
    }
    
    return vc;
}

- (NSUInteger)pageIndexForViewController:(UIViewController *)viewController
{
    NSUInteger index = NSNotFound;
    
    if ([viewController class] == [HistoryTableViewController class]) {
        index = 2;
    } else if ([viewController class] == [PortfilioTableViewController class])
    {
        index = 1;
    } else if ([viewController class] == [FavStocksCollectionViewController class])
    {
        index = 0;
    }
    
    return index;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexForViewController:viewController];
    index--;
    return [self viewControllerAtIndex:index withViewController:viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexForViewController:viewController];
    index++;
    if (index == 3) {
        return nil;
    }
    return [self viewControllerAtIndex:index withViewController:viewController];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
