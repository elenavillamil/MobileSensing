//
//  GraphPoint.h
//  StockApp
//
//  Created by Tyler Hargett on 2/4/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphPoint : NSObject

@property (nonatomic,retain) NSDate *date;
@property (nonatomic) double open;
@property (nonatomic) double close;

+ (GraphPoint *)pointFromDictionary:(NSDictionary *)pointData;

- (double)getPercentChange;
- (double)getChange;

@end
