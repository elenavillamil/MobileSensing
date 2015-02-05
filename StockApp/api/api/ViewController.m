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
    
    BOOL response = [BackendApi setUpAccount:@"jashook" withPassword:@"ev9"];
    
    NSLog(@"%i", response);
    
}
- (IBAction)onClick:(UIButton *)sender {
    //[BackendApi signIn:@"jashook" withPassword:@"ev9"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
