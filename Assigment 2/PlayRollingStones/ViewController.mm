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


#define kBufferLength 4096

@interface ViewController ()

@property (strong, nonatomic) Novocaine* audioManager;
@property (nonatomic) GraphHelper* graphHelper;
@property (nonatomic) AudioFileReader* fileReader;
@property (nonatomic) float* audioData;
@property (nonatomic) SMUFFTHelper* fftHelper;
@property (nonatomic) float* fftMagnitudeBuffer;
@property (nonatomic) float* fftPhaseBuffer;
@property (nonatomic) float* frequencyEqualizer;

@end

@implementation ViewController

RingBuffer *ringBuffer;

- (Novocaine *) audioManager
{
    if (!_audioManager)
    {
        _audioManager = [Novocaine audioManager];
    }
    
    return _audioManager;
}

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

/*- (void) setGraphHelper:(GraphHelper *)graphHelper
 {
 // Do nothing, use the old graphHelper
 }*/

- (AudioFileReader*) fileReader
{
    // nothing :)
    
    return nil;
}

- (float*) audioData
{
    if (!_audioData)
    {
        _audioData = (float*)calloc(kBufferLength,sizeof(float));
    }
    
    return _audioData;
}

- (float*)frequencyEqualizer
{
    if (!_frequencyEqualizer) {
        _frequencyEqualizer = (float*)calloc(20, sizeof(float));
    }
    return _frequencyEqualizer;
}

- (SMUFFTHelper*) fftHelper
{
    if (!_fftHelper)
    {
        //setup the fft
        _fftHelper = new SMUFFTHelper(kBufferLength,kBufferLength,WindowTypeRect);
    }
    
    return _fftHelper;
}

- (float*) fftMagnitudeBuffer
{
    if (!_fftMagnitudeBuffer)
    {
        _fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    }
    
    return _fftMagnitudeBuffer;
}

- (float*) fftPhaseBuffer
{
    if (!_fftPhaseBuffer)
    {
        _fftPhaseBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    }
    
    return _fftPhaseBuffer;
}



#pragma mark - loading and appear
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ringBuffer = new RingBuffer(kBufferLength,2);
    
    self.graphHelper->SetBounds(-0.9,0.9,-0.9,0.9); // bottom, top, left, right, full screen==(-1,1,-1,1)
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         if(ringBuffer!=nil)
             ringBuffer->AddNewFloatData(data, numFrames);
     }];

}

#pragma mark - unloading and dealloc
-(void) viewDidDisappear:(BOOL)animated{
    
    [self.audioManager pause];
    // stop opengl from running
    self.graphHelper->tearDownGL();
}

-(void)dealloc{
    self.graphHelper->tearDownGL();
    
    free(self.audioData);
    
    free(self.fftMagnitudeBuffer);
    free(self.fftPhaseBuffer);
    
    delete self.fftHelper;
    delete ringBuffer;
    delete self.graphHelper;
    
    ringBuffer = nil;
    self.fftHelper  = nil;
    self.audioManager = nil;
    self.graphHelper = nil;
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}

#pragma mark - OpenGL and Update functions
//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    // plot the audio
    ringBuffer->FetchFreshData2(self.audioData, kBufferLength, 0, 1);
    //graphHelper->setGraphData(0,audioData,kBufferLength); // set graph channel
    
    //take the FFT
    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    // plot the FFT
    self.graphHelper->setGraphData(0,self.fftMagnitudeBuffer,kBufferLength/8,sqrt(kBufferLength)); // set graph channel
    
    self.graphHelper->update(); // update the graph
    
    [self performSelector:@selector(getTwoMax:) withObject:nil];

}

-(void)getTwoMax:(id)param
{
    float oldMax = 0.0;
    float maxVal = 0.0;
    float maxOne = 0.0;
    float maxTwo = 0.0;
    int count = 0;
    int windowSize = 24;
    
    for (int i = 0; i < kBufferLength/2; ++i)
    {
        for (int j = 0; j+i < kBufferLength/2 && j < windowSize; ++j)
        {
            if (maxVal < self.fftMagnitudeBuffer[i+j])
            {
                maxVal = self.fftMagnitudeBuffer[i+j];
            }
        }
        
        if (oldMax == maxVal)
        {
            ++count;
            
            if (count == windowSize - 2)
            {
                if (maxVal > maxOne)
                {
                    maxOne = maxVal;
                }
                else if (maxVal > maxTwo)
                {
                    maxTwo = maxVal;
                }
            }
        }
        else
        {
            count = 0;
        }
        
        oldMax = maxVal;
        maxVal = 0.0;
    }
    
    // update local variable if different
    NSLog(@"Max1: %f\n", maxOne);
    NSLog(@"Max2: %f\n", maxTwo);
}

#pragma mark - status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
