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
@property (strong, nonatomic) NSDictionary* runningQueues;
@property int currentWarningTime;

@end

@implementation ViewController

- (NSDictionary*) runningQueus
{
    if (!_runningQueues)
    {
        _runningQueues = [NSDictionary new];
    }
    
    return _runningQueues;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timesForPicker = @[@"5", @"10", @"15", @"20", @"25", @"30"];
    
    [self.timesPicker selectRow:5 inComponent:0 animated:false];
    
    self.currentWarningTime = 30;
    
    // Initializing the bluetooth.
    bleEndpoint = [[BLE alloc] init];
    [bleEndpoint controlSetup];
    
    [self startCountdownToNextEvent];
    
    bleEndpoint.delegate = self;
    
    [self performSelectorInBackground:@selector(bleConnect:) withObject:nil];
    
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) storeChanged
{
    [self startCountdownToNextEvent];
}

- (void) startCountdownToNextEvent
{
    
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    NSArray * calendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    static dispatch_once_t sToken;
    dispatch_once(&sToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeChanged)
                                                    name:EKEventStoreChangedNotification
                                                   object:eventStore];

    });
    
    // 0 has the correct calendar
    // 86400 is time in seconds for 24 hours
    NSPredicate* eventsAsPredicate = [eventStore predicateForEventsWithStartDate:[[NSDate alloc] init] endDate:[[NSDate alloc] initWithTimeIntervalSinceNow:86400] calendars:calendars];
    
    NSArray* eventList = [eventStore eventsMatchingPredicate:eventsAsPredicate];
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int eventsIndexPosition = 0;

            EKEvent* event = [eventList objectAtIndex:eventsIndexPosition];
            
            // The date of the next calendar event.
            NSDate* eventDate = event.startDate;

            int currentValue = self.currentWarningTime;
            
            NSString* selected = [NSString stringWithFormat:@"%d", currentValue];

            if ([self.runningQueues objectForKey:selected])
            {
                // Found a key, we already have a block waiting.
                // Therefore use that one without launching another.
                
                return;
            }
            
            [self.runningQueues setValue:nil forKey:selected];
            
            // Subtract the amount of time to notify the user
            NSDate* workingDate = [eventDate dateByAddingTimeInterval:-currentValue * 60];
            
            NSTimeInterval timeToEvent = [workingDate timeIntervalSinceDate:[NSDate new]];
            
            // Check if the time to the event is less than the warning time.
            // If so just select next event in the calendar.
            while (timeToEvent < self.currentWarningTime)
            {
                eventsIndexPosition += 1;
                event = [eventList objectAtIndex:eventsIndexPosition];
                eventDate = event.startDate;
                
                if ([self.runningQueues objectForKey:selected])
                {
                    // Found a key, we already have a block waiting.
                    // Therefore use that one without launching another.
                    
                    return;
                }
                
                [self.runningQueues setValue:nil forKey:selected];

                workingDate = [eventDate dateByAddingTimeInterval:-currentValue * 60];
                timeToEvent = [workingDate timeIntervalSinceDate:[NSDate new]];
            }
            
            [NSThread sleepForTimeInterval:timeToEvent];
            
            // Check to see if the time interval has been changed, if so we waited x time for nothing.
            // Just fall through.
            
            int checkValue = self.currentWarningTime;
            
            if (currentValue == checkValue)
            {
                // Send the signal to start counting down.
                
                unsigned char dataBuffer[2] = { 2, 0 };
                
                NSData* dataToSend = [NSData dataWithBytes:&dataBuffer length: sizeof(char) * 2];
                
                // Sending the new slider value to the Arduino
                [bleEndpoint write:dataToSend];
            }
            
        });
    
    }];

}

-(void) bleDidConnect
{
    self.connectionLabel.text = @"Connected";
}

-(void) bleDidDisconnect
{
    self.connectionLabel.text = @"Disconnected";
    
    // Functionality to reconnect
    [self bleConnect:nil];
}

// Receiving and proccessing the Data
- (void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData* inputData = [NSData dataWithBytes:data length:length];
    //NSString* parsed_str = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];

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
    
    else if (protocolStatement == 2)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Arduino Alarm" message:@"Meeting specifics here" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            unsigned char dataBuffer[2] = { 3, 0 };
            NSData* dataToSend = [NSData dataWithBytes:&dataBuffer length: sizeof(char) * 2];
                                                                  
            // Sending the new slider value to the Arduino
            [bleEndpoint write:dataToSend];
            
            // Once and event is done, the count down for the next event starts.
            [self startCountdownToNextEvent];
        }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
    
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
            if ([peripheral.name isEqualToString:@"brc"])
            {
                [bleEndpoint connectPeripheral:[bleEndpoint.peripherals objectAtIndex:i]];
            }
            
            // TODO -> Bluetooth name?
            if ([peripheral.name isEqualToString:@"TeamE2"])
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
    
    NSData* dataToSend = [NSData dataWithBytes:&dataBuffer length: sizeof(char) * 2];
    
    // Sending the new slider value to the Arduino
    [bleEndpoint write:dataToSend];
    
    self.currentWarningTime = selected.intValue;
    
    // start a new countdown.
    // The old one now is deprecated and will automatically handle that.
    [self startCountdownToNextEvent];
}


@end
