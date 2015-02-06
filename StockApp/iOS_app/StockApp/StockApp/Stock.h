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
@property (nonatomic, strong) NSString* stockPrice;
@property (nonatomic) NSString* percentChange;
@property (nonatomic) BOOL positive;

@property (nonatomic, strong) NSMutableArray *previousPrices;

- (instancetype)initWithTicker:(NSString*) ticker withPrice:(NSString*) price withPercentage:(NSString*) percentage;

@end
