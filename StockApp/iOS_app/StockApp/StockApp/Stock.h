//
//  Stock.h
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stock : NSObject

@property (nonatomic, strong) NSString *stockName;
@property (nonatomic, strong) NSString *stockTicker;
@property (nonatomic) double stockPrice;
@property (nonatomic) double percentChange;
@property (nonatomic) BOOL positive;

@property (nonatomic, strong) NSMutableArray *previousPrices;

@end
