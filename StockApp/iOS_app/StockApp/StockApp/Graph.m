//
//  Graph.m
//  StockApp
//
//  Created by Tyler Hargett on 2/4/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "Graph.h"
#import "GraphPoint.h"

@interface Graph () <NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *stockPricePoints;

@end

static NSString * const baseURL = @"https://www.quandl.com/api/v1/datasets/WIKI/%@.csv?auth_token=G1ojs7tH3ccD-bf7suSH";

@implementation Graph

- (instancetype)init
{
    if (self = [super init]) {
        _company = [[Stock alloc] init];
    }
    return self;
}

- (NSMutableArray *)stockPricePoints
{
    if (!_stockPricePoints) {
        _stockPricePoints = [[NSMutableArray alloc] init];
    }
    return _stockPricePoints;
}

- (void)getStockGraphData
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:baseURL, @"GOOGL"]]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];

}

- (NSString *)getCurrentPrice
{
    GraphPoint *current = (GraphPoint *)self.stockPricePoints[0];
    return [NSString stringWithFormat:@"%.2f", current.getChange];
}
- (NSString *)getPercentChange
{
    GraphPoint *current = (GraphPoint *)self.stockPricePoints[0];
    return [NSString stringWithFormat:@"%.2f", current.getChange];
}

- (NSInteger)getCount
{
    return [self.stockPricePoints count];
}

- (double)getValueAt:(NSInteger)index
{
    GraphPoint *point = (GraphPoint *)self.stockPricePoints[index];
    return point.close;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseCSV:[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

#pragma mark - Parse CSV

- (void)parseCSV:(NSString *)contents
{
    NSArray* allLinedStrings =[contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    int count = 0;
    for (NSString *line in allLinedStrings)
    {
        
        count++;
        if ([line containsString:@"Close"] || count > 100) {
            
        } else {
            
            if ([line containsString:@"error"]) {
                [self.delegate failedToLoad];
                return;
            }
            GraphPoint* point = [GraphPoint pointFromDictionary:[self seperateLine:line]];
            [self.stockPricePoints addObject:point];
        }
    }
    
    [self.delegate finishedLoading];
}

- (NSDictionary *)seperateLine:(NSString *)line
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    NSArray* allLinedStrings =[line componentsSeparatedByString:@","];
    [data setValue:[allLinedStrings objectAtIndex:0] forKey:@"date"];
    [data setValue:[allLinedStrings objectAtIndex:1] forKey:@"open"];
    [data setValue:[allLinedStrings objectAtIndex:4] forKey:@"close"];
    
    return data;
}



@end
