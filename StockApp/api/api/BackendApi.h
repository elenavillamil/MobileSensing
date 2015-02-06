//
//  BackendApi.h
//  api
//
//  Created by Jarret on 1/31/15.
//  Copyright (c) 2015 Jarret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackendApi : NSObject <NSStreamDelegate>

+ (void)initNetworkConnection;
+ (NSString *)signIn:(NSString*) username withPassword:(NSString*) password;
+ (BOOL)setUpAccount:(NSString *) username withPassword:(NSString *) password;
+ (BOOL)buyOrder:(NSString *) username withStockName:(NSString *)stockName withValue:(double) value withAmount:(size_t) amount;
+ (BOOL)sellOrder:(NSString *) username withStockName:(NSString *)stockName withValue:(double) value withAmount:(size_t) amount;
+ (NSInteger)currentAmountOfMoney:(NSString *) username;
+ (NSMutableArray*) getStockInfo:(NSMutableArray *)stocks;
+ (NSMutableArray*) getHistory:(NSString *) username;
+ (BOOL) addFavorite:(NSString *) username withStockName:(NSString *) stockName;
+ (NSMutableArray *) getFavorites:(NSString *) username;
+ (BOOL) resetAccount:(NSString *)username;
+ (BOOL) removeFavorite:(NSString *)username withStockName:(NSString *) stockName;

@end