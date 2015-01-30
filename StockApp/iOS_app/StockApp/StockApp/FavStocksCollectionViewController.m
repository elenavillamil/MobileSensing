//
//  FavStocksCollectionViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "FavStocksCollectionViewController.h"
#import "HistoryTableViewController.h"
#import "PortfilioTableViewController.h"
#import "FavoriteCollectionViewCell.h"
#import "UIColor+SAColor.h"

@interface FavStocksCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *favoriteStocks;
@property NSInteger favoriteCount;

@end

@implementation FavStocksCollectionViewController

static NSString * const reuseIdentifier = @"FavoriteCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    [self setupCellInsets];
    self.title = @"Favorites";
    self.favoriteCount = 7;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
        
}

#pragma mark - Inits
- (NSMutableArray *)favoriteStocks
{
    if (!_favoriteStocks) {
        _favoriteStocks = [[NSMutableArray alloc] init];
    }
    
    return _favoriteStocks;
}

- (void)setupCellInsets
{
    CGFloat screenWidth = self.view.frame.size.width;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    if (screenWidth < 330.f) {
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(75.f, 5.f, 20.f, 5.f);
    } else if (screenWidth >= 410.f)
    {
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(75.f, 35.f, 20.f, 35.f);
    } else
    {
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(75.f, 20.f, 20.f, 20.f);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.favoriteCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    NSInteger random = arc4random() % 10;
//    [cell setStockName:@"GOOG" withPrice:201.2 withPositive:0];
    if (random > 5) {
        cell.backgroundColor = [UIColor redColor];
    } else
    {
        cell.backgroundColor = [UIColor green];
    }
    cell.stockPriceLabel.text = @"Success";
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Page View Methods

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{

    // Create a new view controller and pass suitable data.
    UIViewController *vc = nil;
    
    switch (index) {
        case 0:
            //already at this page
            break;
            
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PortfolioViewController"];
            break;
            
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
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

// One of the methods called when the user presses the reset button in settings.
-(void)resetFavorites
{
    [self.favoriteStocks removeAllObjects ];
    self.favoriteCount = 0;
}

@end
