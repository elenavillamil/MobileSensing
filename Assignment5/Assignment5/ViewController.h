//
//  ViewController.h
//  Assignment5
//
//  Created by Elena Villamil on 3/28/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "BLE.h"

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, BLEDelegate>
{
    BLE* bleEndpoint;
}

@property (weak, nonatomic) IBOutlet UIPickerView *timesPicker;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *loudnessSlider;
@property (weak, nonatomic) IBOutlet UILabel *brightnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *loudnessLabel;

@end

