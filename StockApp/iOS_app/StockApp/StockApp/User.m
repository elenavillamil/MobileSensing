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

@property (atomic, strong) NSMutableArray *favorites;
@property (atomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSMutableArray *portfolio;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSUserDefaults *loginInformation;
@property double money;


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
        [self readPortfolioFromFile];
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

- (void)addStockToPortfolio:(OwnedStock *)stock
{
    
    for (OwnedStock *s in self.portfolio) {
        if ([s.stockTicker isEqualToString:stock.stockTicker]) {
            s.amount += stock.amount;
            [self writePortfolioToFile];
            
            [BackendApi buyOrder:[self getUsername] withStockName:s.stockTicker withValue:[stock.stockPrice integerValue]  withAmount:stock.amount];
            return;
        }
    }
    [self.portfolio addObject:stock];
    
    [self writePortfolioToFile];
}

- (BOOL)sellStockFromPortfolio:(OwnedStock *)stock
{
    for (OwnedStock *owenedStock in self.portfolio) {
        if ([stock.stockTicker isEqualToString:owenedStock.stockTicker]) {
            if (stock.amount > owenedStock.amount) {
                //selling more then owned
                return NO;
            } else if (stock.amount == owenedStock.amount) {
                [self.portfolio removeObject:owenedStock];
                [self writePortfolioToFile];
                [BackendApi sellOrder:[self getUsername] withStockName:stock.stockTicker withValue:[stock.stockPrice integerValue] withAmount:stock.amount];
                
                return YES;
            } else {
                owenedStock.amount -= stock.amount;
                [self writePortfolioToFile];
                [BackendApi sellOrder:[self getUsername] withStockName:stock.stockTicker withValue:[stock.stockPrice integerValue] withAmount:stock.amount];
                return YES;
            }
        }
    }
    
    //doesnt own stock
    return NO;
}

- (void)writePortfolioToFile
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath] contents:nil attributes:nil];
    }
    //ticker, buyprice, amount
    NSString *writeString = @"";
    for (OwnedStock *stock in self.portfolio) {
       writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%f,%d, \n", stock.stockTicker, stock.purchasePrice,stock.amount]];
    }

    //Moved this stuff out of the loop so that you write the complete string once and only once.

    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
    [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"portfolio.csv"];
}

- (NSMutableArray *)readPortfolioFromFile
{
    NSMutableArray *array = nil;
    
    int column = 0;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* savePath = [paths objectAtIndex:0];
    savePath = [savePath stringByAppendingPathComponent:@"portfolio.csv"];
    
    NSString *fullPath = savePath;
    
    NSMutableArray *titleArray=[[NSMutableArray alloc]init];
    
    NSString *fileDataString=[NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *linesArray=[fileDataString componentsSeparatedByString:@"\n"];
    
    
    int k=0;
    for (id string in linesArray)
        if(k<[linesArray count]-1){
            
            NSString *lineString=[linesArray objectAtIndex:k];
            NSArray *columnArray=[lineString componentsSeparatedByString:@","];
            [titleArray addObject:[columnArray objectAtIndex:column]];
            k++;
            
        }
    
    NSLog(@"%@",titleArray);
    
    return titleArray;
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
    self.money = 10000;
}

-(void)newTimerWith:(NSInteger)time {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    
    // Send new timer/refresh information to the backend
}

-(void)refresh {
    //Get updated info from backend
    
    NSMutableArray* favoriteNames = [BackendApi getFavorites:[self getUsername]];
    [self.favorites removeAllObjects];
    
    if (favoriteNames.count > 0)
    {
        NSMutableArray* stocksInfo = [BackendApi getStockInfo:favoriteNames];
        
        for (int i = 0; i < stocksInfo.count; i+=4)
        {
            Stock* tempStock = [[Stock alloc] initWithTicker:stocksInfo[i] withPrice:stocksInfo[i+1] withPercentage:stocksInfo[i+3]];
            
            [self.favorites addObject:tempStock];
        }
    }
    
    [[self delegate] refreshData];
}

-(void)refreshData {
    
}

-(void)removeFavorite:(Stock *)stock
{
    [self.favorites removeObject:stock];
}

- (NSInteger)getCash
{
    return [BackendApi currentAmountOfMoney:[self getUsername]];
}

@end
