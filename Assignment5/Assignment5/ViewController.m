//
//  ViewController.m
//  Assignment5
//
//  Created by Elena Villamil on 3/28/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic)NSArray* timesForPicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timesForPicker = @[@"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", @"60"];
    
    // Initializing the bluetooth.
    bleEndpoint = [[BLE alloc] init];
    [bleEndpoint controlSetup];
}

-(void) bleDidConnect
{
}

-(void) bleDidDisconnect
{
    // Functionality to reconnect
    [self bleConnect:nil];
}

// Receiving and proccessing the Data
- (void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData* inputData = [NSData dataWithBytes:data length:length];
    
    unsigned char dataBuffer[2] = { 0 };
    
    [inputData getBytes:dataBuffer length:sizeof(char) * 2];
    
    unsigned char protocolStatement = dataBuffer[0];
    int dataPassed = dataBuffer[1];
    
    if (protocolStatement == 0)
    {
        // Light intensity
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loudnessSlider.value = dataPassed;
            
            self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", dataPassed];
        });
    }
    
    else if (protocolStatement == 1)
    {
        // Buzzer intensity
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loudnessSlider.value = dataPassed;
            
            self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", dataPassed];
        });
    }
    
    // 2 - 255 are unused.
    
}

- (void) bleConnect:(id) param
{
    //self._status.text = @"Connecting...";
    
    [NSThread sleepForTimeInterval:.5f];
    
    //start search for peripherals with a timeout of 3 seconds
    // this is an asunchronous call and will return before search is complete
    [bleEndpoint findBLEPeripherals:3];
    
    // Sleep the three seconds
    [NSThread sleepForTimeInterval:3.0f];
    
    if(bleEndpoint.peripherals.count > 0)
    {
        // connect to the first found peripheral
        
        for(int i = 0; i < bleEndpoint.peripherals.count; ++i)
        {
            CBPeripheral* peripheral = [bleEndpoint.peripherals objectAtIndex:i];
            
            // TODO -> Bluetooth name?
            if ([peripheral.name isEqualToString:@"TeamE+2"])
            {
                [bleEndpoint connectPeripheral:[bleEndpoint.peripherals objectAtIndex:i]];
            }
        }
        
    }
}
- (IBAction)brightnessChangeInside:(id)sender {
    // Updating label
    unsigned char currentValue = (char)self.brightnessSlider.value;
    self.brightnessLabel.text = [[NSString alloc] initWithFormat:@"%d", currentValue];
    
    // TODO -> Proper Protocol when creating the data to send
    
    unsigned char protocolBuffer[2] = { 0, currentValue };
    NSData* dataToSend = [NSData dataWithBytes:&protocolBuffer length: sizeof(char) * 2];
    
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
}

- (IBAction)brightnessChangeOutside:(id)sender {
    // Updating label
    unsigned char currentValue = (char)self.brightnessSlider.value;
    self.brightnessLabel.text = [[NSString alloc] initWithFormat:@"%d", currentValue];
    
    // TODO -> Proper Protocol when creating the data to send
    
    unsigned char protocolBuffer[2] = { 0, currentValue };
    NSData* dataToSend = [NSData dataWithBytes:&protocolBuffer length: sizeof(char) * 2];
    
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
    
}

- (IBAction)loudnessChangeInside:(id)sender {
    // Updating label
    unsigned char currentValue = (char)self.loudnessSlider.value;
    self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", currentValue];
    
    // TODO -> Proper Protocol when creating the data to send
    
    unsigned char protocolBuffer[2] = { 1, currentValue };
    
    NSData* dataToSend = [NSData dataWithBytes:&protocolBuffer length: sizeof(char) * 2];
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
}

- (IBAction)loudnessChangeOutside:(id)sender {
    // Updating label
    unsigned char currentValue = (char)self.loudnessSlider.value;
    self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", currentValue];
    
    // TODO -> Proper Protocol when creating the data to send
    
    unsigned char protocolBuffer[2] = { 1, currentValue };
    
    NSData* dataToSend = [NSData dataWithBytes:&protocolBuffer length: sizeof(char) * 2];
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.timesForPicker.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.timesForPicker[row];
}

- (IBAction)onSetTimeClicked:(id)sender {
    NSString* selected = [self.timesForPicker objectAtIndex:[self.timesPicker selectedRowInComponent:0]];
    unsigned char currentValue = (char)selected.intValue;
    
    unsigned char dataBuffer[2] = { 4, currentValue };
    
    // TODO -> Proper Protocol when creating the data to send
    // Getting the height in a byte so it can be send
    NSData* dataToSend = [NSData dataWithBytes:&dataBuffer length: sizeof(char) * 2];
    
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
}


@end
