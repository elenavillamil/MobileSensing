//
//  CompanyProfileViewController.h
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stock.h"

@interface CompanyProfileViewController : UIViewController

- (void)setStock:(Stock *)stock;

- (void)setInfo:(NSString *)ticker withCompanyName:(NSString *)name;

@end
