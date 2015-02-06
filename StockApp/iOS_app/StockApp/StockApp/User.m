//
//  User.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "User.h"
#import "BackendApi.h"

@interface User ()

@property (nonatomic, strong) NSMutableArray *favorites;
@property (atomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSMutableArray *portfolio;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSUserDefaults *loginInformation;


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

-(NSUserDefaults*)loginInformation
{
    if (!_loginInformation)
    {
        _loginInformation = [NSUserDefaults standardUserDefaults];
    }
    
    return _loginInformation;
}

- (NSMutableArray *)favorites
{
    if (!_favorites) {
        _favorites = [[NSMutableArray alloc] init];
    }
    return _favorites;
}

/*- (NSMutableArray *)history
{
    if (_history) {
        _history = [[NSMutableArray alloc] init];
    }
    return _history;
}*/

- (NSMutableArray *)portfolio
{
    if (!_portfolio) {
        _portfolio = [[NSMutableArray alloc] init];
    }
    return _portfolio;
}

-(NSTimer*)timer
{
    if(!_timer) {
        _timer = [[NSTimer alloc] init];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refresh) userInfo:nil repeats:YES];

    }
    return _timer;
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

- (NSString*)getUsername
{
    return [self.loginInformation objectForKey:@"username"];
}

-(NSString*)getPassword
{
    return [self.loginInformation objectForKey:@"password"];
}

-(void)setUsernameWith:(NSString *)username
{
    [self.loginInformation setObject:username forKey:@"username"];
}

-(void)setPasswordWith:(NSString*) password
{
    [self.loginInformation setObject:password forKey:@"password"];
}

-(void)downloadHistory {
    self.history = [BackendApi getHistory:[self getUsername]];
}

-(void)reset {
    // the call to reset on the backend too
    
    [self.history removeAllObjects];
    [self.portfolio removeAllObjects];
    [self.favorites removeAllObjects];
}

-(void)newTimerWith:(NSInteger)time {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    
    // Send new timer/refresh information to the backend
}

-(void)refresh {
    //Get updated info from backend
    
    self.favorites = [BackendApi getFavorites:[self getUsername]];
    
}

-(void)refreshData {
    
}


@end
