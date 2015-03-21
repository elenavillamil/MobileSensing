//
//  ViewController.m
//  SMUOpenCV
//
//  Created by Eric Larson on 2/27/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
using namespace cv;

@interface ViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleTorchButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;
@property Scalar lastAverage;
@property bool firstTime;
@property bool handFound;
@property Scalar originalValue;
@property  double* r;
@property  double* g;
@property  double* b;
@property NSInteger count;
@property int ignoreFrameCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.r = new double[100];
    self.g = new double[100];
    self.b = new double[100];
    self.count = 0;
    
    self.firstTime = true;
    self.handFound = false;
    self.ignoreFrameCount = 15;
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
    
    self.torchIsOn = NO;
    
}

-(void) dealloc {
    delete []self.r;
    delete []self.g;
    delete []self.b;
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
 
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output;
    
    //============================================
    // color inverter
//    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
//    
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    // copy back for further processing
//    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
    //============================================
    //access pixels
//    static uint counter = 0;
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    for(int i=0;i<counter;i++){
//        for(int j=0;j<counter;j++){
//            uchar *pt = image_copy.ptr(i, j);
//            pt[0] = 255;
//            pt[1] = 0;
//            pt[2] = 255;
//            
//            pt[3] = 255;
//            pt[4] = 0;
//            pt[5] = 0;
//        }
//    }
//    cvtColor(image_copy, image, CV_BGR2BGRA);
//    
//    counter++;
//    counter = counter>200 ? 0 : counter;
    
    //============================================
    // get average pixel intensity
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    Scalar avgPixelIntensity = cv::mean(image_copy);
    
    if (self.count >= 100)
    {
        self.count = 0;
    }
    
    self.b[self.count] = avgPixelIntensity.val[0];
    self.g[self.count] = avgPixelIntensity.val[1];
    self.r[self.count++] = avgPixelIntensity.val[2];
    
    // Ignore first valeus of when the camera is turn on.
    if (!self.ignoreFrameCount)
    {
        //NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
        //NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
        
        if (!self.handFound && !self.firstTime && (avgPixelIntensity.val[0] > self.lastAverage.val[0] + 5 || avgPixelIntensity.val[0] < self.lastAverage.val[0] - 5) && (avgPixelIntensity.val[1] > self.lastAverage[1] + 5 || avgPixelIntensity.val[1] < self.lastAverage.val[1] - 5) && (avgPixelIntensity.val[2] > self.lastAverage.val[2] + 5 || avgPixelIntensity.val[2] < self.lastAverage.val[2] - 5))
        {
            //NSLog(@"Finger Found!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            self.handFound = true;
            
            self.ignoreFrameCount = 45;
            
            NSLog(@"Hand Found");
            
            self.originalValue = avgPixelIntensity;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.toggleTorchButton.enabled = NO;
                self.switchCameraButton.enabled = NO;
            });
        }
        
        else if (self.handFound && (avgPixelIntensity.val[0] > self.originalValue.val[0] + 5 || avgPixelIntensity.val[0] < self.originalValue.val[0] - 5) && (avgPixelIntensity.val[1] > self.originalValue[1] + 5 || avgPixelIntensity.val[1] < self.originalValue.val[1] - 5) && (avgPixelIntensity.val[2] > self.originalValue.val[2] + 5 || avgPixelIntensity.val[2] < self.originalValue.val[2] - 5))
        {
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            
            self.handFound = false;
            
            NSLog(@"Removed");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.toggleTorchButton.enabled = YES;
                self.switchCameraButton.enabled = YES;
            });
            
        }
        
        else
        {
            self.firstTime = false;
        }
        
        self.lastAverage = avgPixelIntensity;
    }
    
    else
    {
        --self.ignoreFrameCount;
    }

    
//    char text[50];
//    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
//    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
    //============================================
    // change the hue inside an image
    
    //convert to HSV
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    cvtColor(image_copy, image_copy, CV_BGR2HSV);
//    
//    //grab  just the Hue chanel
//    vector<Mat> layers;
//    cv::split(image_copy,layers);
//    
//    // shift the colors
//    cv::add(layers[0],80.0,layers[0]);
//    
//    // get back image from separated layers
//    cv::merge(layers,image_copy);
//    
//    cvtColor(image_copy, image_copy, CV_HSV2BGR);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif


- (IBAction)toggleTorch:(id)sender {
    // you will need to fix the problem of video stopping when the torch is applied in this method
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
}

- (IBAction)switchCamera:(id)sender {
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    else
    {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    }
    
    [self.videoCamera start];
}

- (void)setTorchOn: (BOOL) onOff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: onOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }

}




@end
