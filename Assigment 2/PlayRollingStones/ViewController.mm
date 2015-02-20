//
//  ViewController.m
//  PlayRollingStones
//
//  Created by Eric Larson on 2/5/14.
//  Copyright (c) 2014 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"
#import "RingBuffer.h"
#import "SMUGraphHelper.h"
#import "SMUFFTHelper.h"


//#define kBufferLength 4096
//#define kBufferLength 8192
#define kBufferLength 16384

@interface ViewController ()

@property (strong, nonatomic) Novocaine* audioManager;
//@property (nonatomic) GraphHelper* graphHelper;
@property (nonatomic) AudioFileReader* fileReader;
@property (nonatomic) float* audioData;
@property (nonatomic) SMUFFTHelper* fftHelper;
@property (nonatomic) float* fftMagnitudeBuffer;
@property (nonatomic) float* fftPhaseBuffer;
@property (nonatomic) float* frequencyEqualizer;
@property (nonatomic) float frequencyOne;
@property (nonatomic) float frequencyTwo;
@property (nonatomic) float deltaFrequency;
@property (weak, nonatomic) IBOutlet UILabel *frequencyOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequencyTwoLabel;

@end

@implementation ViewController

RingBuffer *ringBuffer;

- (Novocaine *) audioManager {
    if (!_audioManager)
    {
        _audioManager = [Novocaine audioManager];
    }
    
    return _audioManager;
}

/*
- (GraphHelper*) graphHelper {
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
*/
- (AudioFileReader*) fileReader {
    // nothing :)
    
    return nil;
}

- (float*) audioData {
    if (!_audioData)
    {
        _audioData = (float*)calloc(kBufferLength,sizeof(float));
    }
    
    return _audioData;
}

- (float*)frequencyEqualizer {
    if (!_frequencyEqualizer) {
        _frequencyEqualizer = (float*)calloc(20, sizeof(float));
    }
    return _frequencyEqualizer;
}

- (SMUFFTHelper*) fftHelper {
    if (!_fftHelper)
    {
        //setup the fft
        _fftHelper = new SMUFFTHelper(kBufferLength,kBufferLength,WindowTypeRect);
    }
    
    return _fftHelper;
}

- (float*) fftMagnitudeBuffer {
    if (!_fftMagnitudeBuffer)
    {
        _fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    }
    
    return _fftMagnitudeBuffer;
}

- (float*) fftPhaseBuffer {
    if (!_fftPhaseBuffer)
    {
        _fftPhaseBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    }
    
    return _fftPhaseBuffer;
}

#pragma mark - loading and appear
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Module A";
    
    ringBuffer = new RingBuffer(kBufferLength,2);
    
    //self.graphHelper->SetBounds(-0.9,0.9,-0.9,0.9); // bottom, top, left, right, full screen==(-1,1,-1,1)
    
    self.frequencyTwo = 0.0;
    
    self.deltaFrequency = self.audioManager.samplingRate  / kBufferLength;
    NSLog(@"DFrequency %f\n", self.deltaFrequency);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
         if(ringBuffer!=nil)
             ringBuffer->AddNewFloatData(data, numFrames);
     }];

}

#pragma mark - unloading and dealloc
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.audioManager pause];
    // stop opengl from running
    //self.graphHelper->tearDownGL();
}

-(void)dealloc{
    
    //self.graphHelper->tearDownGL();
    
    free(self.audioData);
    
    free(self.fftMagnitudeBuffer);
    free(self.fftPhaseBuffer);
    
    delete self.fftHelper;
    delete ringBuffer;
    //delete self.graphHelper;
    
    ringBuffer = nil;
    self.fftHelper  = nil;
    self.audioManager = nil;
    //self.graphHelper = nil;
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}

#pragma mark - OpenGL and Update functions
//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //self.graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    // plot the audio
    ringBuffer->FetchFreshData2(self.audioData, kBufferLength, 0, 1);
    
    //graphHelper->setGraphData(0,audioData,kBufferLength); // set graph channel
    
    //take the FFT
    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    // plot the FFT
    //self.graphHelper->setGraphData(0,self.fftMagnitudeBuffer,kBufferLength/8,sqrt(kBufferLength)); // set graph channel
    
    //self.graphHelper->update(); // update the graph
    
    [self performSelector:@selector(getTwoMax:) withObject:nil];

}

-(void)getTwoMax:(id)param
{
    float oldMax = 0.0;
    float maxVal = 0.0;
    float maxOne = 0.0;
    float maxTwo = 0.0;
    int count = 0;
    int tempPosition = 0;
    int positionOne = 0;
    int positionTwo = 0;
    int windowSize = 22;
    
    // Looking for the local maximums.
    // It is a local maximum if it is the maximum for the entire window.
    for (int i = 0; i < kBufferLength/2; ++i)
    {
        for (int j = 0; j+i < kBufferLength/2 && j < windowSize; ++j)
        {
            if (maxVal < self.fftMagnitudeBuffer[i+j])
            {
                maxVal = self.fftMagnitudeBuffer[i+j];
                tempPosition = i+j;
            }
        }
        
        if (oldMax == maxVal)
        {
            ++count;
            
            if (count > windowSize - 4)
            {
                if (maxVal > maxOne)
                {
                    maxTwo = maxOne;
                    positionTwo = positionOne;
                    maxOne = maxVal;
                    positionOne = tempPosition;
                }
                else if (maxVal > maxTwo)
                {
                    maxTwo = maxVal;
                    positionTwo = tempPosition;
                }
                count = 0;
            }
        }
        else
        {
            count = 0;
        }
        
        oldMax = maxVal;
        maxVal = 0.0;
    }
    
    float newFrequencyOne = [self calculateInterpolation:positionOne];
    float newFrequencyTwo = [self calculateInterpolation:positionTwo];
    
    
    // update local variable if different
    if (maxOne > 8 && (newFrequencyOne > self.frequencyOne + 3 || newFrequencyOne < self.frequencyOne - 3))
    {
        self.frequencyOne = newFrequencyOne;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.frequencyOneLabel.text = [NSString stringWithFormat:@"%.2f", self.frequencyOne];
        });
    }
    if (maxTwo > 8 && (newFrequencyTwo > self.frequencyTwo + 3 || newFrequencyTwo < self.frequencyTwo - 3))
    {
        self.frequencyTwo = newFrequencyTwo;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.frequencyTwoLabel.text = [NSString stringWithFormat:@"%.2f", self.frequencyTwo];
        });
    }
}

-(float) calculateInterpolation:(int)position
{
    float frequency = 0.0;
    
    // Interpolation equation: f2 + (m3 - m2) / (2m2 - m1 - m2) * Af/2

    // Getting (m3 - m2) / (2*m2 - m1 - m2)
    float temp = (self.fftMagnitudeBuffer[position + 1] - self.fftMagnitudeBuffer[position]) / (2*self.fftMagnitudeBuffer[position] - self.fftMagnitudeBuffer[position - 1] - self.fftMagnitudeBuffer[position]);
    
    // Af = sampling rate / points -> has to be around 6 change buffer size
    
    frequency = (position * self.deltaFrequency) + (temp * self.deltaFrequency / 2);
    
    return frequency;
}

//#pragma mark - status bar
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

@end
