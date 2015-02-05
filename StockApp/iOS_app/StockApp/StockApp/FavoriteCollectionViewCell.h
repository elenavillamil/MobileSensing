//
//  FavoriteCollectionViewCell.h
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPercentChange;
@property (nonatomic) BOOL positiveChange;


@end
