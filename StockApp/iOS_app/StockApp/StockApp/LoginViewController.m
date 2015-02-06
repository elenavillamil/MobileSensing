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
#import "BackendApi.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) User *user;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPressedUp:)];
    [self.view addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)tapPressedUp:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUp:(id)sender{
    // connect to back end;
    
    if ([BackendApi setUpAccount:self.usernameTextField.text withPassword:self.passwordTextField.text])
    {        
        // saving an NSString
        [self.user setUsernameWith:self.usernameTextField.text];
        [self.user setPasswordWith:self.passwordTextField.text];
        
        UINavigationController *nav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NavigationViewController"];
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
    }
    else
    {
        // Making and showing pop up to let the user know that the account could not be created
        UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The username already exists, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert_view show];
        self.usernameTextField.text = @"";
        self.passwordTextField.text = @"";
    }
}

- (IBAction)login:(id)sender {
    // connect to back end;
    
    if (![[BackendApi signIn:self.usernameTextField.text withPassword:self.passwordTextField.text] isEqualToString:@"Login failed"])
    {
        // saving an NSString
        [self.user setUsernameWith:self.usernameTextField.text];
        [self.user setPasswordWith:self.passwordTextField.text];
        
        UINavigationController *nav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NavigationViewController"];
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
    }
    else
    {
        // Making and showing pop up to let the user know that the account could not be created
        UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The username or the password are incorrect, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert_view show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else{
        [self.passwordTextField resignFirstResponder];
    }
    
    return YES;
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
