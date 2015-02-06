//
//  User.h
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stock.h"

@protocol UserDelegate <NSObject>

- (void)refreshData;

@end

@interface User : NSObject <UserDelegate>

@property (nonatomic, strong) id <UserDelegate> delegate;

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
-(void)setUsernameWith:(NSString *)username;
-(void)setPasswordWith:(NSString *)password;
-(NSString*)getUsername;
-(NSString*)getPassword;
-(void)downloadHistory;
-(void)removeFavorite:(Stock*)stock;

@end
