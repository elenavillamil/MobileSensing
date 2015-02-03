//
//  LoginViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "LoginViewController.h"
#import "FavStocksCollectionViewController.h"
#import "User.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) User *user;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUp:(id)sender{
    bool connection = true;
    // connect to back end;
    
    if (connection)
    {        
        // saving an NSString
        [self.user setUsernameWith:self.usernameTextField.text];
        [self.user setPasswordWith:self.passwordTextField.text];
    }
}

- (IBAction)login:(id)sender {
    bool connection = true;
    // connect to back end;
    
    if (connection)
    {
        // saving an NSString
        [self.user setUsernameWith:self.usernameTextField.text];
        [self.user setPasswordWith:self.passwordTextField.text];
        
        UINavigationController *nav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NavigationViewController"];
        
        [self.view.window setRootViewController:nav];
        
        //Change root navigation to favorite
//        [self performSegueWithIdentifier:@"NavigationController" sender:self];
    }
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
