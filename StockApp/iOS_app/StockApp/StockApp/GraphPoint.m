//
//  GraphPoint.m
//  StockApp
//
//  Created by Tyler Hargett on 2/4/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "GraphPoint.h"

@implementation GraphPoint


+ (GraphPoint *)pointFromDictionary:(NSDictionary *)pointData
{
    GraphPoint *point = [[GraphPoint alloc] init];
    
    point.close = [[pointData valueForKey:@"close"] doubleValue];
    point.open = [[pointData valueForKey:@"open"] doubleValue];
    
    
    NSString *dateString = [NSString stringWithFormat:@"%@",[pointData valueForKey:@"date"]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-dd-MM"];
    point.date = [dateFormat dateFromString:dateString];
    
    return point;
}

- (double)getPercentChange
{
    return [self getChange] / self.open;
}

- (double)getChange
{
    return self.close - self.open;
}

@end
