//
//  SettingsViewController.h
//  StockApp
//
//  Created by Tyler Hargett on 1/27/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *simulationSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *timerSegmentedControl;

- (IBAction)onSimulationSwitchValueChange:(id)sender;

- (IBAction)onTimerSegmentedControlValueChange:(id)sender;

- (IBAction)onResetButtonTouchUpInside:(id)sender;

- (IBAction)onSignOutButtonTouchUpInside:(id)sender;

@end
