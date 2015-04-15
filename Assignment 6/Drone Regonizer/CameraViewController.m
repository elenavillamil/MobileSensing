//
//  CameraViewController.m
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/15/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController () {
    AVCaptureStillImageOutput *stillImageOutput;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *lastPictureImageView;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic) BOOL isFlashOn;
@property (nonatomic) BOOL isForward;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

    self.navigationController.navigationBar.hidden = YES;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.imageView.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
//    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:@"AVCaptureStillImageIsCapturingStillImageContext"];
    if ( [session canAddOutput:stillImageOutput] )
        [session addOutput:stillImageOutput];
    
    [session startRunning];
    
    
    self.session = session;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhoto:(id)sender {
    AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (error) {
                                                          //error
                                                      }
                                                      else {
                                                          // trivial simple JPEG case
                                                          NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                          [self.delegate addTargetPhoto:[UIImage imageWithData:jpegData]];
                                                          [self.lastPictureImageView setImage:[UIImage imageWithData:jpegData]];
                                                      }
                                                      }];
    
    
}

- (IBAction)flipCamera:(id)sender {
}

- (IBAction)flipFlash:(id)sender {
}

- (void)addTargetPhoto:(UIImage *)photo {
    //shouldnt get here.
}

@end
