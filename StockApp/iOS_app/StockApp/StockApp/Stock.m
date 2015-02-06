//
//  Stock.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "Stock.h"

@implementation Stock


- (instancetype)init
{
    if (self = [ super init])
    {
        
    }
    return self;
}

- (instancetype)initWithTicker:(NSString*) ticker withPrice:(NSString*) price withPercentage:(NSString*) percentage
{
    if (self = [super init])
    {
        self.stockTicker = ticker;
        self.stockPrice = price;
        self.percentChange = percentage;
        if ([percentage characterAtIndex:0] == '+')
        {
            self.positive = true;
        }
        else
        {
            self.positive = false;
        }
    }
    
    return self;
}

- (NSString *)stockName
{
    if (!_stockName) {
        _stockName = [NSString init];
    }
    
    return _stockName;
}

- (NSString *)stockPrice
{
    if (!_stockPrice) {
        _stockPrice = [NSString init];
    }
    
    return _stockPrice;
}

- (NSString *)stockTicker
{
    if (!_stockTicker) {
        _stockTicker = [NSString init];
    }
    
    return _stockTicker;
}

- (NSString *)percentChange
{
    if (!_percentChange) {
        _percentChange = [NSString init];
    }
    
    return _percentChange;
}

- (BOOL)positive
{
    if (!_positive) {
        _positive = false;
    }
    
    return _positive;
}






@end
