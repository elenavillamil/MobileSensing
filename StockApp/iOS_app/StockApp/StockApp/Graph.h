//
//  Graph.h
//  StockApp
//
//  Created by Tyler Hargett on 2/4/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stock.h"

@protocol GraphDelegate <NSObject>

- (void)finishedLoading;
- (void)failedToLoad;

@end


@interface Graph : NSObject {
    
}

@property (nonatomic, retain) Stock *company;
@property (retain) id<GraphDelegate> delegate;


+(Graph *)sharedInstance;

- (void)getStockGraphData;
- (NSString *)getCurrentPrice;
- (NSString *)getPercentChange;
- (NSInteger)getCount;
- (double)getValueAt:(NSInteger)index;
@end
