//
//  ViewController.m
//  api
//
//  Created by Jarret on 1/31/15.
//  Copyright (c) 2015 Jarret. All rights reserved.
//

#import "ViewController.h"
#import "BackendApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [BackendApi initNetworkConnection];
    
    if (![BackendApi setUpAccount:@"elena2" withPassword:@"elenavillamil"])
    {
        NSInteger response = [BackendApi currentAmountOfMoney:@"elena2"];
        NSLog(@"%li", (long)response);
        NSArray* stocks = @[@"msft", @"amzn"];
        [BackendApi resetAccount:@"elena2"];
        
    }
    
}
- (IBAction)onClick:(UIButton *)sender {
    //[BackendApi signIn:@"jashook" withPassword:@"ev9"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
