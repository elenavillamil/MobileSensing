//
//  HistoryStopTableViewCell.h
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryStopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stockStickerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceLabel;

@end
