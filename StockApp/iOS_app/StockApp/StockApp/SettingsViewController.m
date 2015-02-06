//
//  SettingsViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+SAColor.h"
#import "User.h"
#import "BackendApi.h"

@interface SettingsViewController ()

@property(strong,nonatomic)User* user;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Settings";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    self.navigationController.navigationBar.barTintColor = [UIColor blue];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (User *)user
{
    if (!_user) {
        _user = [User sharedInstance];
    }
    
    return _user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSimulationSwitchValueChange:(id)sender {
    if ([self.simulationSwitch isOn])
    {
        // Hide all views except the stock info
        // In company view hide the lower part
        
    }
    else
    {
        
    }
}

-(IBAction)onTimerSegmentedControlValueChange:(id)sender{
    NSString* newTime = [sender titleForSegmentAtIndex:self.timerSegmentedControl.selectedSegmentIndex];
    // Set NSTimer to this number
    [self.user newTimerWith:newTime.integerValue];
}

- (IBAction)onResetButtonTouchUpInside:(id)sender {
    // Call reset on db
    [self.user reset];
    [BackendApi resetAccount:[self.user getUsername]];
}

- (IBAction)onSignOutButtonTouchUpInside:(id)sender {
}
@end
