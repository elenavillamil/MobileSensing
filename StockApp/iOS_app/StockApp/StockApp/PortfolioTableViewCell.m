//
//  PortfolioTableViewCell.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "PortfolioTableViewCell.h"

@implementation PortfolioTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (Stock *)companyStock
{
    if (!_companyStock) {
        _companyStock = [[Stock alloc] init];
    }
    return _companyStock;
}

@end
