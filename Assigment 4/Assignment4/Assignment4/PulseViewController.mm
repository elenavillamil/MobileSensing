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

#define sampleRate 30          //Default # samples / second, this value WILL NOT be used for the actual sampling rate
#define ringBufferLength 450   //Length of the ring buffer being used for video data, 15 seconds
#define N 10 //The number of images which construct a time series for each pixel
#define PI 3.14159
#define graphWidth 450.0           //Width (in Hz) of the section of the graph that is displayed
#define FRAMES_PER_SECOND 30;
#define FILTER_ORDER 5;

#define COUNT_MAX 100
#define FPS 30

typedef struct
{
    double r;       // percent
    double g;       // percent
    double b;       // percent
} rgb;

typedef struct
{
    double h;       // angle in degrees
    double s;       // percent
    double v;       // percent
} hsv;

float currentFrequency = 30.0;

// Heart rate lower limit [bpm]
#define BPM_L 10

// Heart rate higher limit [bpm]
#define BPM_H 300

@interface PulseViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIButton *checkPulseButton;
@property (nonatomic) GraphHelper* graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;
@property Scalar lastAverage;
@property bool firstTime;
@property bool fingerDetected;
@property bool checkPulse;
@property Scalar originalValue;
@property double hue;
@property NSInteger count;
@property int ignoreFrameCount;
@property int countFrames;
@property int heartRate;

@property NSMutableArray* unfiltered_hues;
@property (nonatomic) float *pulseData;
@property (nonatomic) int startingPoint;
@property (nonatomic) int endPoint;

@end

@implementation PulseViewController

//This is declared here in order to bypass Automatic Reference Counting (ARC)...
//If this was declared as a property, the block using it would retain a strong
//reference to it and the memory would never be deallocated
//RingBuffer *ringBuffer;

float hueValues[countMax];
int count;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Zero out our buffer.
    memset(hueValues, 0, countMax);
    count = 0;
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);
    
    self.hue = 0.0;
    self.count = 0;
    
    self.firstTime = false;
    self.fingerDetected = false;
    self.ignoreFrameCount = 60;  // ignore first two seconds of data to give them 2 seconds to place this finger
    self.countFrames = 0;
    self.checkPulse = false;
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = FRAMES_PER_SECOND;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
    
    [self setTorchIsOn:NO];

    //[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTorchIsOn:NO];
}

-(void)dealloc {
    // Graph
    self.graphHelper->tearDownGL();
    delete self.graphHelper;
    self.graphHelper = nil;
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.graphHelper->tearDownGL();
    
    // FORCE TORCH OFF
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
                                       PlotStyleSeparated); // Drawing starts immediately after call
        
        _graphHelper->SetBounds(-0.9,0.9,-0.9,0.9);
    }
    
    return _graphHelper;
}




//  override the GLKView draw function, from OpenGLES
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}


#pragma mark - Imaging


-(float*)pulseData {
    if(!_pulseData)
        _pulseData = (float*)calloc(ringBufferLength, sizeof(float));
    
    return _pulseData;
}

-(int)startingPoint {
    if (!_startingPoint) {
        _startingPoint = (currentFrequency - (graphWidth / 2)) / (sampleRate/(float)ringBufferLength);
    }
    return _startingPoint;
}

-(int)endPoint {
    if (!_endPoint) {
        _endPoint = (currentFrequency + (graphWidth / 2)) / (sampleRate/(float)ringBufferLength);
    }
    return _endPoint;
}

//  override the GLKViewController update function, from OpenGLES
- (void)update{
//    const size_t windowSize = 30;
//        float* data = (float*)malloc(sizeof(float) * 300);
//    
//        for (int i = 1; i < 300; i++)
//        {
//            float x = float(i);
//            if (x > 150) {
//                x -= (x-150);
//            }
//    
//            data[i] = x+100;
//        }
    
    // Plot the audio
    ringBuffer->FetchFreshData2(self.pulseData, ringBufferLength, 1, 1);
    
    // Filter
    
    // Take the FFT
    // self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    // Get peaks from FFT data
    //[self getPeaks];
    
    //[self dBmagnitude];
    
    // Plot the filtered
    //self.graphHelper->setGraphData(0,self.pulseData + self.startingPoint, self.endPoint - self.startingPoint, sqrt(ringBufferLength)/60/30); // set graph channel
    
    self.graphHelper->update(); // update the graph
}

- (IBAction)startPulseMeter:(id)sender 
{
    if (self.checkPulse == false) {
        
        
        self.checkPulse = true;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    }
    else {
        self.checkPulse = false;
    }
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    Mat image_copy;
    Mat grayFrame, output;

    cvtColor(image, image_copy, CV_BGRA2BGR);   // get rid of alpha for processing
    Scalar avg_BGR = cv::mean(image_copy);
    cvtColor(image, image_copy, CV_BGR2HSV);    // convert to HSV to get Hue
    Scalar avg_HSV= cv::mean(image_copy);
    int blueGreen = avg_BGR[1] + avg_BGR[0];
    //NSLog(@"Red: %.1f, Green: %.1f, Blue: %.1f", avg_BGR[2], avg_BGR[1], avg_BGR[0]);
    NSLog(@"Val: %.1f, Sat: %.1f, Hue: %.1f", avg_HSV[2], avg_HSV[1], avg_HSV[0]);
    
    if (!self.ignoreFrameCount)
    {
        // get hue value only
        self.hue = avg_HSV.val[0];
        
        // Start capturing all the data needed.

    }
    else
    {
        --self.ignoreFrameCount;
    }
}

#endif

- (void)keepRednessFactor: (Scalar) avgBGRvals
{
    
}

// partially developed from MATLAB found at http://www.ignaciomellado.es/blog/Measuring-heart-rate-with-a-smartphone-camera
- (void)butterworthFilter
{
//    static const int BPM_L = 40;                        // Heart rate lower limit [bpm]
//    static const int BPM_H = 230;                       // Heart rate higher limit [bpm]
    //static const int FILTER_STABILIZATION_TIME = 1;     // [seconds]
    
    //double scaleFactor = [self sf_bwbp :2 :BPM_L/60.0 :BPM_H/60.0];  // divide by 60 to convert to seconds
    // Butterworth frequencies must be in [0, 1], where 1 corresponds to half the sampling rate
   // double cornerLow = (BPM_L/60.0)*scaleFactor;
    //double cornerHigh = (BPM_H/60.0)*scaleFactor;
   
    //time series of 5
    double y[5];
    double x[5]={1,2,3,4,5};
 //   [self filter :FILTER_ORDER :DenC :NumC :5 :x :y];
    
}


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

- (void)setTorchOff: (BOOL) onOff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    
}

#pragma mark - Data processing

//  Following Code adapted from...
//  HeartRateDetection.m
//  ATHeartRate
//
//  Created by Brandon Lehner on 3/16/15.
//  Copyright (c) 2015 Brandon Lehner. All rights reserved.
//

- (NSArray *)butterworthBandpassFilter:(NSArray *)inputData
{
    const int NZEROS = 8;
    const int NPOLES = 8;
    static float xv[NZEROS+1], yv[NPOLES+1];
    
    // http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
    // Butterworth Bandpass filter
    // 4th order
    // sample rate - varies between possible camera frequencies. Either 30, 60, 120, or 240 FPS
    // corner1 freq. = 0.667 Hz (assuming a minimum heart rate of 40 bpm, 40 beats/60 seconds = 0.667 Hz)
    // corner2 freq. = 4.167 Hz (assuming a maximum heart rate of 250 bpm, 250 beats/60 secods = 4.167 Hz)
    // Bandpass filter was chosen because it removes frequency noise outside of our target range (both higher and lower)
    double dGain = 1.232232910e+02;
    
    NSMutableArray *outputData = [[NSMutableArray alloc] init];
    for (NSNumber *number in inputData)
    {
        double input = number.doubleValue;
        
        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
        xv[8] = input / dGain;
        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
        yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
        + ( -0.1397436053 * yv[0]) + (  1.2948188815 * yv[1])
        + ( -5.4070037946 * yv[2]) + ( 13.2683981280 * yv[3])
        + (-20.9442560520 * yv[4]) + ( 21.7932169160 * yv[5])
        + (-14.5817197500 * yv[6]) + (  5.7161939252 * yv[7]);
        
        [outputData addObject:@(yv[8])];
    }
    
    return outputData;
}


// Find the peaks in our data - these are the heart beats.
// At a 30 Hz detection rate, assuming 250 max beats per minute, a peak can't be closer than 7 data points apart.
- (int)peakCount:(NSArray *)inputData
{
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

- (int)peakDetection:(double*) points count:( int) numOfPoints {
    static int window = 16;
    
    int numOfPeaks = 0;
    double* peaks = (double*)malloc(sizeof(double) * numOfPoints);
    
    
    for (int index  = 0 ; index < numOfPoints; ++index) {
        double sPoint = points[index];
        double max = sPoint;
        int tempMaxPostion = 0;
        
        for (int start = index+1; start < numOfPoints && start < window; ++start) {
            if (max < points[start]) {
                max = points[start];
                tempMaxPostion = start - index;
                
            }
        }
        
        if (tempMaxPostion == window/2 ) {
            peaks[numOfPeaks] = index;
            numOfPeaks++;
        }
    }
    
    int heartBeat = 0;
    
    for (int index = 1; index < numOfPeaks; index++) {
        heartBeat += peaks[index] - peaks[index-1];
    }
    heartBeat /= numOfPeaks*2;
    
    return heartBeat;
}

#pragma mark Hardware - torch & camera

- (IBAction)toggleTorch:(id)sender {
    // you will need to fix the problem of video stopping when the torch is applied in this method
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
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
