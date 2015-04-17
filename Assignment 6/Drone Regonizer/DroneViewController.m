//
//  DroneViewController.m
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/16/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "DroneViewController.h"

@interface DroneViewController ()

@end

@implementation DroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;

    self.navigationItem.leftBarButtonItem.enabled = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
