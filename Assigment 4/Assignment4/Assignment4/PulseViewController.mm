//
//  PulseViewController.m
//  Assignment4
//
//  Created by Tyler Hargett on 3/17/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

#import "PulseViewController.h"
#import "SMUGraphHelper.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
using namespace cv;


@interface PulseViewController () <CvVideoCameraDelegate>

@property (nonatomic) GraphHelper* graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
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

@implementation PulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);

//    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];


    
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
    
    [self setTorchIsOn:NO];

    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTorchIsOn:YES];
}

-(void)dealloc {
    //graph
    self.graphHelper->tearDownGL();
    delete self.graphHelper;
    self.graphHelper = nil;
    //pixels
    delete []self.r;
    delete []self.g;
    delete []self.b;
}

#pragma mark - Graphing

- (GraphHelper*) graphHelper
{
    // start animating the graph
    const static int framesPerSecond = 30;
    const static int numDataArraysToGraph = 1;
    
    if (!_graphHelper)
    {
        _graphHelper = new GraphHelper(self,
                                       framesPerSecond,
                                       numDataArraysToGraph,
                                       PlotStyleSeparated);//drawing starts immediately after call
    }
    
    return _graphHelper;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)updateGraph {
    const size_t windowSize = 30;
    float* data = (float*)malloc(sizeof(float) * 300);
    
    for (int i = 1; i < 300; i++)
    {
        float x = float(i);
        if (x > 150) {
            x -= (x-150);
        }
        
        data[i] = x+100;
    }
    
    
    self.graphHelper->setGraphData(0, data, windowSize, 0);
    self.graphHelper->update();
    free(data);
    data = nil;

}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}


#pragma mark - Imaging

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output;
    
    
    
    //============================================
    // change the hue inside an image
    
    //convert to HSV
        cvtColor(image, image_copy, CV_BGRA2BGR);
        cvtColor(image_copy, image_copy, CV_BGR2HSV);
    
        //grab  just the Hue chanel
        vector<Mat> layers;
        cv::split(image_copy,layers);
    
        // shift the colors
        cv::add(layers[0],80.0,layers[0]);
    
        // get back image from separated layers
        cv::merge(layers,image_copy);
    
        cvtColor(image_copy, image_copy, CV_HSV2BGR);
        cvtColor(image_copy, image, CV_BGR2BGRA);
    
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
        
        float* graphData = (float *)malloc(sizeof(float) * self.count);
        for (int i = 0; i < self.count; i++) {
            graphData[i] = float(self.r[i]);
        }
        
        self.graphHelper->setGraphData(0, graphData, 30, 0);
        self.graphHelper->update();
        
        if (!self.handFound && !self.firstTime && (avgPixelIntensity.val[0] > self.lastAverage.val[0] + 5 || avgPixelIntensity.val[0] < self.lastAverage.val[0] - 5) && (avgPixelIntensity.val[1] > self.lastAverage[1] + 5 || avgPixelIntensity.val[1] < self.lastAverage.val[1] - 5) && (avgPixelIntensity.val[2] > self.lastAverage.val[2] + 5 || avgPixelIntensity.val[2] < self.lastAverage.val[2] - 5))
        {
            //NSLog(@"Finger Found!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            self.handFound = true;
            
            self.ignoreFrameCount = 45;
            
            NSLog(@"Hand Found");
            
            self.originalValue = avgPixelIntensity;
            
        }
        else if (self.handFound && (avgPixelIntensity.val[0] > self.originalValue.val[0] + 5 || avgPixelIntensity.val[0] < self.originalValue.val[0] - 5) && (avgPixelIntensity.val[1] > self.originalValue[1] + 5 || avgPixelIntensity.val[1] < self.originalValue.val[1] - 5) && (avgPixelIntensity.val[2] > self.originalValue.val[2] + 5 || avgPixelIntensity.val[2] < self.originalValue.val[2] - 5))
        {
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            
            self.handFound = false;
            
            NSLog(@"Removed");
            
        } else
        {
            self.firstTime = false;
        }
        
        self.lastAverage = avgPixelIntensity;
    }
    
    else
    {
        --self.ignoreFrameCount;
    }

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
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
