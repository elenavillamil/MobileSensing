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
    m_ble_endpoint = [[BLE alloc] init];
    [m_ble_endpoint controlSetup];
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
    NSData* input_data = [NSData dataWithBytes:data length:length];
    NSString* parsed_str = [[NSString alloc] initWithData:input_data encoding:NSUTF8StringEncoding];
    
    
}

// Connecting to BRC (basketball robot controler) bluetooth.
- (void) bleConnect:(id) param
{
    //self._status.text = @"Connecting...";
    
    [NSThread sleepForTimeInterval:.5f];
    
    //start search for peripherals with a timeout of 3 seconds
    // this is an asunchronous call and will return before search is complete
    [m_ble_endpoint findBLEPeripherals:3];
    
    // Sleep the three seconds
    [NSThread sleepForTimeInterval:3.0f];
    
    if(m_ble_endpoint.peripherals.count > 0)
    {
        // connect to the first found peripheral
        
        for(int i = 0; i < m_ble_endpoint.peripherals.count; ++i)
        {
            CBPeripheral* peripheral = [m_ble_endpoint.peripherals objectAtIndex:i];
            
            // TODO -> Bluetooth name?
            if ([peripheral.name isEqualToString:@"TeamE+2"])
            {
                [m_ble_endpoint connectPeripheral:[m_ble_endpoint.peripherals objectAtIndex:i]];
            }
        }
        
    }
}
- (IBAction)brightnessChangeInside:(id)sender {
    // Updating label
    int current_value = self.brightnessSlider.value;
    self.brightnessLabel.text = [[NSString alloc] initWithFormat:@"%d", current_value];
    
    // TODO -> Proper Protocol when creating the data to send

    NSData* data_to_send = [NSData dataWithBytes:&current_value length: 1];
    //Sending the new slider value to the Arduino
    [m_ble_endpoint write:data_to_send];
}

- (IBAction)brightnessChangeOutside:(id)sender {
    // Updating label
    int current_value = self.brightnessSlider.value;
    self.brightnessLabel.text = [[NSString alloc] initWithFormat:@"%d", current_value];
    
    // TODO -> Proper Protocol when creating the data to send

    NSData* data_to_send = [NSData dataWithBytes:&current_value length: 1];
    //Sending the new slider value to the Arduino
    [m_ble_endpoint write:data_to_send];
    
}

- (IBAction)loudnessChangeInside:(id)sender {
    // Updating label
    int current_value = self.loudnessSlider.value;
    self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", current_value];
    
    // TODO -> Proper Protocol when creating the data to send
    
    NSData* data_to_send = [NSData dataWithBytes:&current_value length: 1];
    //Sending the new slider value to the Arduino
    [m_ble_endpoint write:data_to_send];
}

- (IBAction)loudnessChangeOutside:(id)sender {
    // Updating label
    int current_value = self.loudnessSlider.value;
    self.loudnessLabel.text = [[NSString alloc] initWithFormat:@"%d", current_value];
    
    // TODO -> Proper Protocol when creating the data to send

    NSData* data_to_send = [NSData dataWithBytes:&current_value length: 1];
    //Sending the new slider value to the Arduino
    [m_ble_endpoint write:data_to_send];
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
    int current_value = selected.intValue;
    
    // TODO -> Proper Protocol when creating the data to send
    //Getting the height in a byte so it can be send
    NSData* data_to_send = [NSData dataWithBytes:&current_value length: 1];
    
    //Sending the new slider value to the Arduino
    [m_ble_endpoint write:data_to_send];
}


@end
