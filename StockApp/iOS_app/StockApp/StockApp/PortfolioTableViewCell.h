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

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *stockTickerLabel;

@end
