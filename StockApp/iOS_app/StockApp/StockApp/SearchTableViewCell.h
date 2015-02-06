//
//  SearchTableViewCell.h
//  StockApp
//
//  Created by Tyler Hargett on 2/5/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tickerLabel;

@end
