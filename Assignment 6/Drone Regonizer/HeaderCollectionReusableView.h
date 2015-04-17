//
//  HeaderCollectionReusableView.h
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/16/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TargetNameDelegate <NSObject>

- (void)setName:(NSString *)name;

@end


@interface HeaderCollectionReusableView : UICollectionReusableView <UITextFieldDelegate, TargetNameDelegate>{
    id <TargetNameDelegate> delegate;
}

@property (retain) id <TargetNameDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
