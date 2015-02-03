//
//  PortfolioTableViewCell.h
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stock.h"

@interface PortfolioTableViewCell : UITableViewCell

@property (nonatomic, strong) Stock *companyStock;

@end
