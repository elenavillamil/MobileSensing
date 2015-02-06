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







@end
