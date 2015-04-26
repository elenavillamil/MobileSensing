//
//  HeaderCollectionReusableView.m
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/16/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "HeaderCollectionReusableView.h"

@implementation HeaderCollectionReusableView

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate setName:self.nameTextField.text];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.delegate setName:self.nameTextField.text];
    [textField resignFirstResponder];
    return YES;
}

- (void)setName:(NSString *)name {
    //shouldnt get here.
}

@end
