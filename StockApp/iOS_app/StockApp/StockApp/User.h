//
//  User.h
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stock.h"

@interface User : NSObject

+ (User *)sharedInstance;

- (void)addFavorite:(Stock *)stock;
- (void)addStockToPortfolio:(Stock *)stock;
- (void)addHistoryItem: (id)object;

- (NSMutableArray *)getFavorites;
- (NSMutableArray *)getPortfolio;
- (NSMutableArray *)getHistory;

-(void)reset;
-(void)newTimerWith:(NSInteger)time;
-(void)refresh;

@end
