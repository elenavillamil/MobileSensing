//
//  DroneViewController.m
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/16/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "DroneViewController.h"
#import "MBJoystickView.h"


@interface DroneViewController ()
@property (weak, nonatomic) IBOutlet MBJoystickView *joystick;

@end

@implementation DroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    
    [self.joystick setThumbRadius:44];
    [self.joystick setDeadRadius:10.0f];
    [[self view] addSubview:self.joystick];
    
    [self.joystick setBackgroundImage:[UIImage imageNamed:@"dpad"]];
    [self.joystick setThumbImage:[UIImage imageNamed:@"joystick"]];
    [self observeControls];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;

    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void) observeControls{
    [self.joystick addObserver:self forKeyPath:@"velocity" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dispatchJoystickChangedNotificationWithSender:(id)sender{
    NSLog(@"Joystick: %@", sender);
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([object isKindOfClass:[MBJoystickView class]]) {
        if ([keyPath isEqual:@"velocity"]) {
            [self dispatchJoystickChangedNotificationWithSender:object];
        }
    }
}

- (IBAction)connectDrone:(id)sender {
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
