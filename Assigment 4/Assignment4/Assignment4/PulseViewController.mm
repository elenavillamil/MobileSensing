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
#import "RingBuffer.h"

using namespace cv;

#define PI 3.14159
#define graphWidth 450.0           //Width (in Hz) of the section of the graph that is displayed
#define FRAMES_PER_SECOND 30

#define BUFFERED_FRAMES 300
#define WINDOW_SIZE 17

// TIME INTERVALS
int fps = FRAMES_PER_SECOND;        // some math functions will not work with FRAMES_PER_SECOND in the denominator
float seconds = BUFFERED_FRAMES/fps;
float minutes = seconds/60;

@interface PulseViewController () <CvVideoCameraDelegate>
@property (nonatomic) GraphHelper* graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;

@property bool fingerDetected;
@property int peakCount;


@end

@implementation PulseViewController

//This is declared here in order to bypass Automatic Reference Counting (ARC)...
//If this was declared as a property, the block using it would retain a strong
//reference to it and the memory would never be deallocated
//RingBuffer *ringBuffer;
float hueValues[BUFFERED_FRAMES];
float pulseData[BUFFERED_FRAMES];
float filteredHueValues[BUFFERED_FRAMES];
int frameCount;
int ignoreFrameCount = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Zero out our buffer.
    memset(hueValues, 0, BUFFERED_FRAMES * sizeof(float));
    frameCount = 0;
    
    self.graphHelper->SetBounds(-0.5, 0.5, -0.9, 0.9);
    
    self.peakCount = 0;
    
    self.fingerDetected = false;
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = FRAMES_PER_SECOND;
    self.videoCamera.grayscaleMode = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartRateLabel.text = @" ";
    });
    
    [self.videoCamera start];
    
    [self setTorchIsOn:NO];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
}

-(void)dealloc {
    // Graph
    //delete self.graphHelper;
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    memset(hueValues, 0, BUFFERED_FRAMES * sizeof(float));
    
    // FORCE TORCH OFF
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.graphHelper->tearDownGL();
    delete self.graphHelper;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - Graphing

- (GraphHelper*) graphHelper
{
    // start animating the graph
    const static int numDataArraysToGraph = 1;
    
    if (!_graphHelper)
    {
        _graphHelper = new GraphHelper(self,
                                       fps,
                                       numDataArraysToGraph,
                                       PlotStyleSeparated); // Drawing starts immediately after call
        
        _graphHelper->SetBounds(-0.7,0.7,-0.9,0.9);
    }
    return _graphHelper;
}

//  override the GLKView draw function, from OpenGLES
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}


#pragma mark - Imaging

- (void)update{

    self.graphHelper->setGraphData(0, pulseData, BUFFERED_FRAMES, sqrt(BUFFERED_FRAMES)); // set graph channel
    
    self.graphHelper->update(); // update the graph
}



#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    Mat image_copy;

    cvtColor(image, image_copy, CV_BGRA2BGR);   // get rid of alpha for processing
    //Scalar avg_BGR = cv::mean(image_copy);
    cvtColor(image, image_copy, CV_BGR2HSV);    // convert to HSV to get Hue
    Scalar avg_HSV= cv::mean(image_copy);
    //int blueGreen = avg_BGR[1] + avg_BGR[0];
    //NSLog(@"Red: %.1f, Green: %.1f, Blue: %.1f", avg_BGR[2], avg_BGR[1], avg_BGR[0]);
    NSLog(@"Val: %.1f, Sat: %.1f, Hue: %.1f", avg_HSV[2], avg_HSV[1], avg_HSV[0]);
    
    if (!ignoreFrameCount)
    {
        
        if (frameCount == BUFFERED_FRAMES)
        {
            // puts filtered hue values through a median smoother and counts the peaks
            self.peakCount = [self getPeakCount];
            float heart_bpm = self.peakCount / minutes;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.heartRateLabel.text = [NSString stringWithFormat:@"%.0f", heart_bpm];
            });
            self.peakCount = 0;
            frameCount = 0;
        }
        
        // store filtered hue value
        pulseData[frameCount++] = [self butterworth:avg_HSV.val[0]];
    }
    else
    {
        --ignoreFrameCount;
    }
}
#endif


#pragma mark Hardware - torch & camera

//http://sugartin.info/2012/03/13/switching-the-flash-light-on-and-off/

- (void)setTorchOn: (BOOL) onOff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: onOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}


- (IBAction)toggleTorch:(id)sender {
    // you will need to fix the problem of video stopping when the torch is applied in this method
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
}

#pragma mark - Data processing

/* 
    4th order Butterworth Bandpass filter 
    a blend of an implementation found here
    http://stackoverflow.com/questions/664877/i-need-to-implement-a-butterworth-filter-in-c-is-it-easier-get-a-library-with-t, 
    and one found here https://github.com/lehn0058/ATHeartRate, which is a model file of an app called ATHeartRate.
    sample rate - varies between possible camera frequencies. Either 30, 60, 120, or 240 FPS
    corner1 freq. = 0.667 Hz (assuming a minimum heart rate of 40 bpm, 40 beats/60 seconds = 0.667 Hz)
    corner2 freq. = 4.167 Hz (assuming a maximum heart rate of 250 bpm, 250 beats/60 secods = 4.167 Hz)
    Research shows that the bandpass Butterworth (4th order) is a good filter to use to eliminate higher and lower frequency noise from our "signal"
    This website http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript was used to generate MatLab code that provided the coefficents for this filter, as well as the gain value.
 */

-(float)butterworth: (float) input
{
    const int NZEROS = 8;
    const int NPOLES = 8;
    static float xv[NZEROS+1], yv[NPOLES+1];
    float dGain = 1.232232910e+02;
    
    xv[0] = xv[1];
    xv[1] = xv[2];
    xv[2] = xv[3];
    xv[3] = xv[4];
    xv[4] = xv[5];
    xv[5] = xv[6];
    xv[6] = xv[7];
    xv[7] = xv[8];
    xv[8] = input / dGain;
    
    yv[0] = yv[1];
    yv[1] = yv[2];
    yv[2] = yv[3];
    yv[3] = yv[4];
    yv[4] = yv[5];
    yv[5] = yv[6];
    yv[6] = yv[7];
    yv[7] = yv[8];
    yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
            + ( -0.1397436053 * yv[0]) + (  1.2948188815 * yv[1])
            + ( -5.4070037946 * yv[2]) + ( 13.2683981280 * yv[3])
            + (-20.9442560520 * yv[4]) + ( 21.7932169160 * yv[5])
            + (-14.5817197500 * yv[6]) + (  5.7161939252 * yv[7]);
    
    return (yv[8]);
}


//  Following Code adapted from...
//  HeartRateDetection.m
//  ATHeartRate
//
//  Created by Brandon Lehner on 3/16/15.
//  Copyright (c) 2015 Brandon Lehner. All rights reserved.
//

// Find the peaks in our data - these are the heart beats.
// At a 30 Hz detection rate, assuming 250 max beats per minute, a peak can't be closer than 7 data points apart.
- (int)getPeakCount
{
    NSMutableArray *butteredPulse = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < BUFFERED_FRAMES; i++){
        [butteredPulse insertObject:[NSNumber numberWithFloat:pulseData[i]] atIndex:i];
    }
    
    NSArray *inputData = [self medianSmoothing:butteredPulse];
    
    if (inputData.count == 0)
        {
        return 0;
    }
    
    int count = 0;
    
    for (int i = 3; i < inputData.count - 3;)
    {
        if (inputData[i] > 0 &&
            [inputData[i] doubleValue] > [inputData[i-1] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-2] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-3] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+1] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+2] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+3] doubleValue]
            )
        {
            count = count + 1;
            i = i + 4;
        }
        else
        {
            i = i + 1;
        }
    }

    return count;
}

// Smoothed data helps remove outliers that may be caused by interference, finger movement or pressure changes.
// This will only help with small interference changes.
// This also helps keep the data more consistent.
- (NSArray *)medianSmoothing:(NSArray *)inputData
{
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < inputData.count; i++)
    {
        if (i == 0 ||
            i == 1 ||
            i == 2 ||
            i == inputData.count - 1 ||
            i == inputData.count - 2 ||
            i == inputData.count - 3)
        {
            [newData addObject:inputData[i]];
        }
        
        else
        {
            NSArray *items = [@[
                                inputData[i-2],
                                inputData[i-1],
                                inputData[i],
                                inputData[i+1],
                                inputData[i+2],
                                ] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            
            [newData addObject:items[2]];
        }
    }
    
    return newData;
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
