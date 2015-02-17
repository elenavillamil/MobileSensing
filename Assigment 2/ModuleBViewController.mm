//
//  RootViewController.m
//  PlayRollingStones
//
//  Created by Elena Villamil on 2/11/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ModuleBViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"
#import "RingBuffer.h"
#import "SMUGraphHelper.h"
#import "SMUFFTHelper.h"

#define AVERAGE_SIZE 5
#define SAMPLE_AMOUNT 4096

@interface ModuleBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *frequenceValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *frequenceValueSlider;
@property double currentSoundPlayFrequence;
@property (weak, nonatomic) Novocaine* audioManager;

@property (nonatomic) GraphHelper* graphHelper;
@property (nonatomic) AudioFileReader* fileReader;
@property (nonatomic) float* audioData;
@property (nonatomic) SMUFFTHelper* fftHelper;
@property (nonatomic) float* fftMagnitudeBuffer;
@property (nonatomic) float* fftPhaseBuffer;
@property (nonatomic) float* frequencyEqualizer;

@end

@implementation ModuleBViewController

RingBuffer *ringBufferModuleB;

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
        _audioData = (float*)calloc(SAMPLE_AMOUNT, sizeof(float));
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
        _fftHelper = new SMUFFTHelper(SAMPLE_AMOUNT, SAMPLE_AMOUNT, WindowTypeRect);
    }
    
    return _fftHelper;
}

- (float*) fftMagnitudeBuffer
{
    if (!_fftMagnitudeBuffer)
    {
        _fftMagnitudeBuffer = (float *)calloc(SAMPLE_AMOUNT / 2, sizeof(float));
    }
    
    return _fftMagnitudeBuffer;
}

- (float*) fftPhaseBuffer
{
    if (!_fftPhaseBuffer)
    {
        _fftPhaseBuffer = (float *)calloc(SAMPLE_AMOUNT/2,sizeof(float));
    }
    
    return _fftPhaseBuffer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ringBufferModuleB = new RingBuffer(SAMPLE_AMOUNT, 1);
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);
}

- (void) viewWillAppear:(BOOL)animated {
    // Start a noise.
    static bool initialized = false;
    
    if (!initialized) {
        
        __block float frequency = 261.0; //starting frequency
        __block float phase = 0.0;
        __block float samplingRate = self.audioManager.samplingRate;

        [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {

             double phaseIncrement = 2*M_PI*frequency/samplingRate;
             double repeatMax = 2*M_PI;
             for (int i=0; i < numFrames; ++i) {
                 for(int j=0;j<numChannels;j++) {
                     data[i*numChannels+j] = 0.8*sin(phase);
                 }
                 phase += phaseIncrement;

                 if(phase>repeatMax)
                     phase -= repeatMax;
             }}];
        
        initialized = true;
    }
    
    [self.audioManager play];
    
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         if(ringBufferModuleB!=nil)
             ringBufferModuleB->AddNewFloatData(data, numFrames);
     }];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.audioManager pause];
    
    self.graphHelper->tearDownGL();
}

-(void)dealloc {
    self.graphHelper->tearDownGL();
    
    free(self.audioData);
    free(self.fftMagnitudeBuffer);
    free(self.fftPhaseBuffer);
    
    delete self.fftHelper;
    delete ringBufferModuleB;
    delete self.graphHelper;
    
    ringBufferModuleB = nil;
    self.fftHelper = nil;
    self.audioManager = nil;
    self.graphHelper = nil;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}

-(void)update {
    ringBufferModuleB->FetchFreshData(self.audioData, SAMPLE_AMOUNT, 0, 1);
    
    self.fftHelper->forward(0, self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    self.graphHelper->setGraphData(0, self.fftMagnitudeBuffer, SAMPLE_AMOUNT / 8, sqrt(SAMPLE_AMOUNT));
    
    self.graphHelper->update();
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)averageArrays:(float**) array withSize:(size_t) size {
    
    // Loop over the amount of arrays to average
    // Add everything into the first array
    for (size_t index = 1; index < size; ++index) {
        
        // Loop over the total amount of samples
        for (size_t sampleIndex = 0; sampleIndex < SAMPLE_AMOUNT; ++sampleIndex) {
            array[0][sampleIndex] += array[index][sampleIndex];
            
        }
        
    }
    
    // Loop over the total amount of samples and calculate the average
    // by dividing by the amount of samples added together
    for (size_t sampleIndex = 0; sampleIndex < SAMPLE_AMOUNT; ++sampleIndex) {
        array[0][sampleIndex] /= size;
        
    }
}

// Not Thread safe! Do not call from two threads in parallel!
- (bool)determineAction {
    
    // cache the float arrays
    static float* cachedFloatArrs[AVERAGE_SIZE];
    static size_t cachedArrIndex = 0;
    
    if (cachedArrIndex % AVERAGE_SIZE)
    {
        cachedFloatArrs[cachedArrIndex++] = 0;
    } else {
        cachedArrIndex = 0;
        
        [self averageArrays:cachedFloatArrs withSize:AVERAGE_SIZE];
        
        // The average is stored in the first array
        float* averagedArr = cachedFloatArrs[0];
        
        
    }
    
    return false;
}

- (IBAction)onSliderChange:(id)sender {
    self.currentSoundPlayFrequence = self.frequenceValueSlider.value;
    
    self.frequenceValueLabel.text = [NSString stringWithFormat:@"%.2f", self.currentSoundPlayFrequence];
}
@end
