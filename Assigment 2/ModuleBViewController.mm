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

#define AVERAGE_SIZE 0
#define SAMPLE_AMOUNT 4096

@interface ModuleBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *frequenceValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *frequenceValueSlider;
@property double currentSoundPlayFrequence;
@property (strong, nonatomic) Novocaine* audioManager;

@property (nonatomic) GraphHelper* graphHelper;
@property (nonatomic) AudioFileReader* fileReader;
@property (nonatomic) float* audioData;
@property (nonatomic) SMUFFTHelper* fftHelper;
@property (nonatomic) float* fftMagnitudeBuffer;
@property (nonatomic) float* fftPhaseBuffer;
@property (nonatomic) float* frequencyEqualizer;
@property (nonatomic) float deltaFrequency;

@end

@implementation ModuleBViewController

RingBuffer *ringBufferModuleB;
float frequency = 17500.0; //starting frequency

typedef enum {
    MovingAway,
    MovingTowards,
    NotMoving
} MovingAction;

- (double) currentSoundPlayFrequence {
    if (!_currentSoundPlayFrequence) {
        _currentSoundPlayFrequence = 17500;
    }
    
    return _currentSoundPlayFrequence;
}

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
    
    self.deltaFrequency = self.audioManager.samplingRate  / SAMPLE_AMOUNT/2;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);

    // Start a noise.
    static bool initialized = false;
    
    if (!initialized) {
        
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
        
        //initialized = true;
    }
    
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         if(ringBufferModuleB!=nil)
             ringBufferModuleB->AddNewFloatData(data, numFrames);
     }];
    
    if(![self.audioManager playing]){
        [self.audioManager play];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
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
    static int skipCount = 1;
    static size_t const amountToSkip = AVERAGE_SIZE;
    
    ringBufferModuleB->FetchFreshData2(self.audioData, SAMPLE_AMOUNT, 0, 1);
    self.fftHelper->forward(0, self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    float* averagedArray;
    
    int action = [self determineAction:self.fftMagnitudeBuffer withUpdateArray:&averagedArray];
    
    if (AVERAGE_SIZE == 0 || skipCount % amountToSkip == 0) {
        const size_t windowSize = 250;
        
        size_t frequencyIndex = frequency / (44100 / (SAMPLE_AMOUNT));
        
        float* startPoint = &averagedArray[frequencyIndex] - windowSize;
        
        self.graphHelper->setGraphData(0, startPoint, windowSize * .95, sqrt(SAMPLE_AMOUNT));
        
        self.graphHelper->update();
    }
    
    if (AVERAGE_SIZE) {
        // Reset the counter if AVERAGE_SIZE times has passed
        skipCount = skipCount % amountToSkip == 0 ? 1 : skipCount + 1;
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

- (void) subtractArrays:(float*)firstArray withSecondArray:(float*)secondArray {
    for (size_t index = 0; index < SAMPLE_AMOUNT; ++index) {
        firstArray[index] -= secondArray[index];
    }
}

- (void) toDecibles:(float*)array {
    for (size_t index = 0; index < SAMPLE_AMOUNT / 2; ++index) {
        array[index] = 20 * log10(array[index]);
    }
}

// Not Thread safe! Do not call from two threads in parallel!
//
// Returns: Enum MovingAction
//
// -1: MovingAway
// 1 : Moving Towards
// 0 : NoMovement
- (MovingAction)determineAction:(float*) magnitudeArr withUpdateArray:(float**) arrayToUpdate {
    // cache the float arrays
    static float** cachedFloatArrs;
    static size_t cachedArrIndex = 1;
    static bool initialized = false;
    
    if (!cachedFloatArrs) {
        if (AVERAGE_SIZE == 0) {
            cachedFloatArrs = (float**)malloc(sizeof(float*) * 1);
            *cachedFloatArrs = NULL;
            
            *cachedFloatArrs = (float*)malloc(sizeof(float) * SAMPLE_AMOUNT);
            memset(*cachedFloatArrs, 0, sizeof(SAMPLE_AMOUNT));
        } else {
            cachedFloatArrs = (float**)malloc(sizeof(float*) * AVERAGE_SIZE - 1);
            memset(cachedFloatArrs, 0, sizeof(float*) * AVERAGE_SIZE - 1);
            
            for (size_t index = 0; index < AVERAGE_SIZE - 1; ++index) {
                cachedFloatArrs[index] = (float*)malloc(sizeof(float) * SAMPLE_AMOUNT);
            }
        }
    }
    
    if (AVERAGE_SIZE != 0) {
        if (cachedArrIndex % AVERAGE_SIZE == 0) {
            cachedArrIndex = 1;
            
            [self averageArrays:cachedFloatArrs withSize:AVERAGE_SIZE - 1];
            
            // The average is stored in the first array
            *arrayToUpdate = cachedFloatArrs[0];
            
            [self toDecibles:*arrayToUpdate];
            [self toDecibles:magnitudeArr];
            
            //[self subtractArrays:*arrayToUpdate withSecondArray:magnitudeArr];
            
        } else {
            memcpy(cachedFloatArrs[(cachedArrIndex++) - 1], self.fftMagnitudeBuffer, sizeof(float) * SAMPLE_AMOUNT);
        }
    } else {
        if (!initialized && magnitudeArr[0] != 0) {
            memcpy(*cachedFloatArrs, magnitudeArr, SAMPLE_AMOUNT);
            
            [self toDecibles:*cachedFloatArrs];
            
            initialized = true;
        }
        
        [self toDecibles:magnitudeArr];
        *arrayToUpdate = magnitudeArr;
        
        for (size_t index = 0; index < AVERAGE_SIZE; ++index) {
            magnitudeArr[index] -= *cachedFloatArrs[index];
        }
    }
    
    return NotMoving;
}

- (IBAction)onSliderChange:(id)sender {
    frequency = self.frequenceValueSlider.value;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frequenceValueLabel.text = [NSString stringWithFormat:@"%.2f", frequency];
    });
}
@end
