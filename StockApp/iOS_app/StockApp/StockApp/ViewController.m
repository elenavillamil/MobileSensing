//
//  ViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "ViewController.h"
#import "HistoryTableViewController.h"
#import "FavStocksCollectionViewController.h"
#import "PortfilioTableViewController.h"
#import "UIColor+SAColor.h"
#import "SettingsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setBarTintColor:[UIColor blue]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;

    FavStocksCollectionViewController *startingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavStocksCollectionViewController"];
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.backgroundColor = [UIColor lightGrayColor];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0.f, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.navigationItem.title = @"Favorites";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Methods

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    // Create a new view controller and pass suitable data.
    UIViewController *vc = nil;
    
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FavStocksCollectionViewController"];
            break;
            
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PortfilioTableViewController"];
            break;
            
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryTableViewController"];
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
        self.navigationItem.title = @"History";
        index = 2;
    } else if ([viewController class] == [PortfilioTableViewController class])
    {
        self.navigationItem.title = @"Portfolio";
        index = 1;
    } else if ([viewController class] == [FavStocksCollectionViewController class])
    {
        index = 0;
        self.navigationItem.title = @"Favorites";
    }
    
    return index;
}

- (IBAction)settingButtonPressed:(id)sender {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    [self.navigationController presentViewController:settingNav animated:YES completion:nil];
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexForViewController:viewController];
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexForViewController:viewController];
    index++;
    if (index == 3) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
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
