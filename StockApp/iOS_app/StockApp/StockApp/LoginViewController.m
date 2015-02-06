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
#import "Stock.h"

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

- (User *)user
{
    if (!_user) {
        _user = [User sharedInstance];
    }
    return _user;
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
    
    NSString * username = self.usernameTextField.text;
    NSString * password = self.passwordTextField.text;
    
    bool areValidString = true;
    
    for (size_t index = 0; index < [username length]; ++index)
    {
        char usernameChar = [username characterAtIndex:index];
        char lowerUsernameChar = tolower(usernameChar);

        if (lowerUsernameChar < 'a' || lowerUsernameChar > 'z')
        {
            areValidString = false;
            
            // Making and showing pop up to let the user know that the account could not be created
            UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The username contains invalid characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert_view show];
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            
            break;
        }
    }
    
    for (size_t index = 0; index < [password length]; ++index)
    {
        char passwordChar = [password characterAtIndex:index];
        char lowerPasswordChar = tolower(passwordChar);
        
        if (lowerPasswordChar < ' ')
        {
            areValidString = false;
            
            // Making and showing pop up to let the user know that the account could not be created
            UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The password cannot contain spaces" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert_view show];
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            
            break;
        }
    }
    
    if (areValidString)
    {
        if ([BackendApi setUpAccount:self.usernameTextField.text withPassword:self.passwordTextField.text])
        {
            // saving an NSString
            [self.user setUsernameWith:self.usernameTextField.text];
            [self.user setPasswordWith:self.passwordTextField.text];
            
            // Getting the users favorite stocks information
            [self getFavoriteStocksInfo:self.usernameTextField.text];
            
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
}

- (IBAction)login:(id)sender {
    // connect to back end;
    
    NSString * username = self.usernameTextField.text;
    NSString * password = self.passwordTextField.text;
    
    bool areValidString = true;
    
    for (size_t index = 0; index < [username length]; ++index)
    {
        char usernameChar = [username characterAtIndex:index];
        char lowerUsernameChar = tolower(usernameChar);
        
        if (lowerUsernameChar < 'a' || lowerUsernameChar > 'z')
        {
            areValidString = false;
            
            // Making and showing pop up to let the user know that the account could not be created
            UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The username contains invalid characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert_view show];
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            
            break;
        }
    }
    
    for (size_t index = 0; index < [password length]; ++index)
    {
        char passwordChar = [password characterAtIndex:index];
        char lowerPasswordChar = tolower(passwordChar);
        
        if (lowerPasswordChar == ' ')
        {
            areValidString = false;
            
            // Making and showing pop up to let the user know that the account could not be created
            UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:@"Invalid action" message:@"The password cannot contain spaces" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert_view show];
            self.usernameTextField.text = @"";
            self.passwordTextField.text = @"";
            
            break;
        }
    }
    
    if (areValidString)
    {
        if (![[BackendApi signIn:self.usernameTextField.text withPassword:self.passwordTextField.text] isEqualToString:@"Login failed"])
        {
            // saving an NSString
            [self.user setUsernameWith:username];
            [self.user setPasswordWith:password];
            
            // Get user favorite stocks and the stocks information.
            [self getFavoriteStocksInfo:self.usernameTextField.text];
            
            [self.user newTimerWith:3];
            
            [self performSelectorInBackground:@selector(startThread) withObject:nil];
            
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
}

- (void) startThread
{
    [self.user downloadHistory];
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

-(void) getFavoriteStocksInfo:(NSString*) username
{
    NSMutableArray* stocksNames = [BackendApi getFavorites:username];
    if(stocksNames.count > 0)
    {
        NSMutableArray* stocksInfo = [BackendApi getStockInfo:stocksNames];
    
        for (int i = 0; i < stocksInfo.count; i+=4)
        {
            Stock* tempStock = [[Stock alloc] initWithTicker:stocksInfo[i] withPrice:stocksInfo[i+1] withPercentage:stocksInfo[i+3]];

            [self.user addFavorite:tempStock];
        }
    }

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
