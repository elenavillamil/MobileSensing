//
//  FavStocksCollectionViewController.h
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavStocksCollectionViewController : UICollectionViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;

-(void) resetFavorites;

@end
