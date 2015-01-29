//
//  User.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "User.h"

@interface User ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSMutableArray *portfolio;

@end

@implementation User

+ (User *)sharedInstance
{
    static User *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
    });
    return sharedUser;
}

- (NSMutableArray *)favorites
{
    if (!_favorites) {
        _favorites = [[NSMutableArray alloc] init];
    }
    return _favorites;
}

- (NSMutableArray *)history
{
    if (_history) {
        _history = [[NSMutableArray alloc] init];
    }
    return _history;
}

- (NSMutableArray *)portfolio
{
    if (!_portfolio) {
        _portfolio = [[NSMutableArray alloc] init];
    }
    return _portfolio;
}

- (void)addFavorite:(Stock *)stock
{
    [self.favorites addObject:stock];
}

- (void)addStockToPortfolio:(Stock *)stock
{
    [self.portfolio addObject:stock];
}

- (void)addHistoryItem: (id)object
{
    [self.history addObject:object];
}

- (NSMutableArray *)getFavorites
{
    return self.favorites;
}

- (NSMutableArray *)getPortfolio
{
    return self.portfolio;
}

- (NSMutableArray *)getHistory
{
    return self.history;
}


@end
