//
//  UIColor+SAColor.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "UIColor+SAColor.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation UIColor (SAColor)

+ (UIColor *)green
{
    return UIColorFromRGB(0x4CD964);
}

+ (UIColor *)blue
{
    return [UIColor colorWithRed:6/255.f green:122/255.f blue:181/255.f alpha:1];
}

@end
