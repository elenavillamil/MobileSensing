//
//  FavoriteCollectionViewCell.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "FavoriteCollectionViewCell.h"
#import "UIColor+SAColor.h"

@implementation FavoriteCollectionViewCell

- (void)setPositiveChange:(BOOL)positiveChange
{
    if (positiveChange) {
        self.backgroundColor = [UIColor green];
    } else {
        self.backgroundColor = [UIColor redColor];
    }
    _positiveChange = positiveChange;
}

@end
