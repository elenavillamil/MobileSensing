//
//  FavoriteCollectionViewCell.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "FavStocksCollectionViewController.h"
#import "FavoriteCollectionViewCell.h"

@implementation FavoriteCollectionViewCell


- (void)setStockName:(NSString *)name withPrice:(double)price withPositive:(BOOL)positive
{
    self.stockNameLabel.text = name;
    self.stockPriceLabel.text = [NSString stringWithFormat:@"$%f",price];
}

@end
