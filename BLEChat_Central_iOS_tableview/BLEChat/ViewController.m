//
//  ViewController.m
//  BLEChat
//
//  Created by Cheong on 15/8/12.
//  Modified by Eric Larson, 2014
//  Copyright (c) 2012 RedBear Lab., All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // CHANGE 1.a: change this as you no longer need to instantiate the BLE Object
    //bleShield = [[BLE alloc] init];
    //[bleShield controlSetup];
    //bleShield.delegate = self;
    
    //CHANGE 4: add subscription to notifications from the app delegate
    //These selector functions should be created from the old BLEDelegate functions
    // One example has already been completed for you on the receiving of data function
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidConnect:) name:@"BLEDidConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidDisconnect:) name:@"BLEDidDisconnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidUpdateRSSI:) name:@"BLEUpdatedRSSI" object:nil];
    
    // this example function "OnBLEDidReceiveData:" is done for you, see below
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (OnBLEDidReceiveData:) name:@"BLEReceievedData" object:nil];
}

// CHANGE 3: Add support for lazy instantiation (like we did in the table view controller)
-(BLE*)bleShield
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}


//setup auto rotation in code
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - RSSI timer
NSTimer *rssiTimer;
-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bleShield readRSSI]; // be sure that the RSSI is up to date
}

//#pragma mark - BLEdelegate protocol methods
//-(void) bleDidUpdateRSSI:(NSNumber *)rssi
//{
//    self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
//}

-(void) OnBLEDidUpdateRSSI:(NSNotification *)notification
{
    NSNumber* rssi = [[notification userInfo] objectForKey:@"RSSI"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
    });
}

// OLD FUNCITON: parse the received data using BLEDelegate protocol
/*-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.label.text = s;
}
*/

// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) OnBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = s;
    });
}

// we disconnected, stop running
//- (void) bleDidDisconnect
//{
//    //CHANGE 5.b: remove all instances of the button at top
//    [self.buttonConnect setTitle:@"Connect" forState:UIControlStateNormal];
//    
//    [rssiTimer invalidate];
//}

// we disconnected, stop running
- (void) OnBLEDidDisconnect:(NSNotification *)notification
{
    //CHANGE 5.b: remove all instances of the button at top
    
    [rssiTimer invalidate];
}

//CHANGE 7: create function called from "BLEDidConnect" notification (you can change the function below)
// in this function, update a label on the UI to have the name of the active peripheral
// you might be interested in the following method:
// NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
// now just wait to send or receive
//-(void) bleDidConnect
//{
//    //CHANGE 5.a: Remove all usage of the connect button and remove from storyboard
//    [self.spinner stopAnimating];
//    [self.buttonConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
//    
//    // Schedule to read RSSI every 1 sec.
//    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
//}

-(void) OnBLEDidConnect:(NSNotification *)notification
{
    //CHANGE 5.a: Remove all usage of the connect button and remove from storyboard
    //[self.spinner stopAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelPeripheralName.text = [[notification userInfo] objectForKey:@"deviceName"];
    });
    
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

#pragma mark - UI operations storyboard
- (IBAction)BLEShieldSend:(id)sender
{
    
    //Note: this function only needs a name change, the BLE writing does not change
    NSString *s;
    NSData *d;
    
    if (self.textField.text.length > 16)
        s = [self.textField.text substringToIndex:16];
    else
        s = self.textField.text;

    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
}


// CHANGE 1.b: change this as you no longer need to search for perpipherals in this view controller
/*- (IBAction)BLEShieldScan:(id)sender
{
    // disconnect from any peripherals
    if (bleShield.activePeripheral)
        if(bleShield.activePeripheral.isConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    // set peripheral to nil
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    //start search for peripherals with a timeout of 3 seconds
    // this is an asunchronous call and will return before search is complete
    [bleShield findBLEPeripherals:3];
    
    // after three seconds, try to connect to first peripheral
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0
                                     target:self
                                   selector:@selector(connectionTimer:)
                                   userInfo:nil
                                    repeats:NO];
    
    // give connection feedback to the user
    [self.spinner startAnimating];
}
 */

// CHANGE 1.c: change this as you no longer need to create the connection in this view controller
// Called when scan period is over to connect to the first found peripheral
/*-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        // connect to the first found peripheral
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
        [self.spinner stopAnimating];
    }
}
*/
@end
