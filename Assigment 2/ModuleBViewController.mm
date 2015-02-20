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
#import "ZoomMapViewController.h"

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
@property (weak, nonatomic) ZoomMapViewController* child;

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
    
//    self.graphHelper->tearDownGL();
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
    
    const size_t windowSize = 30;
    size_t frequencyIndex = frequency / (self.audioManager.samplingRate / (float)(SAMPLE_AMOUNT));
    size_t startIndex = frequencyIndex - windowSize / 2;
    
    int action = [self determineAction:self.fftMagnitudeBuffer withUpdateArray:&averagedArray withStartIndex:startIndex withSize:windowSize * .95 withFrequencyIndex:frequencyIndex withFrequency:frequency];
    
    if (action == MovingAway) {
        NSLog(@"Moving Away");
    } else if (action == MovingTowards) {
        NSLog(@"Moving Towards");
    } else {
        NSLog(@"Not Moving");
    }
    
    if (AVERAGE_SIZE == 0 || skipCount % amountToSkip == 0) {
        self.graphHelper->setGraphData(0, averagedArray == NULL ? self.fftMagnitudeBuffer : averagedArray, windowSize * .95, sqrt(SAMPLE_AMOUNT));
        
        self.graphHelper->update();
    }
    
    if (AVERAGE_SIZE) {
        // Reset the counter if AVERAGE_SIZE times has passed
        skipCount = skipCount % amountToSkip == 0 ? 1 : skipCount + 1;
    }
}


- (void)averageArrays:(float**) array withSize:(size_t) size {
    
    // Loop over the amount of arrays to average
    // Add everything into the first array
    for (size_t index = 1; index < size; ++index) {
        
        // Loop over the total amount of samples
        for (size_t sampleIndex = 0; sampleIndex < size; ++sampleIndex) {
            array[0][sampleIndex] += array[index][sampleIndex];
            
        }
        
    }
    
    // Loop over the total amount of samples and calculate the average
    // by dividing by the amount of samples added together
    for (size_t sampleIndex = 0; sampleIndex < size; ++sampleIndex) {
        array[0][sampleIndex] /= size;
        
    }
}

- (void) subtractArrays:(float*)firstArray withSecondArray:(float*)secondArray {
    for (size_t index = 0; index < SAMPLE_AMOUNT / 2; ++index) {
        firstArray[index] -= secondArray[index];
    }
}

- (void) toDecibles:(float*)array withSize:(size_t) size {
    for (size_t index = 0; index < size; ++index) {
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
- (MovingAction)determineAction:(float*) magnitudeArr withUpdateArray:(float**) arrayToUpdate withStartIndex:(size_t)startIndex withSize:(size_t) size withFrequencyIndex:(size_t) frequencyIndex withFrequency:(float) currentFrequency {
    // cache the float arrays
    static float* cachedFloatArrs;
    static size_t cachedArrIndex = 1;
    static bool initialized = false;
    static float sFrequency = frequency;
    
    static size_t count = 0;
    
    static float leftBaseLine = 0;
    static float rightBaseLine = 0;
    
    static size_t catchUp = 0;
    
    // How many times have we called this function
    ++count;
    
    if (!cachedFloatArrs) {
        // Not averaging, therefore just make array
        
        cachedFloatArrs = (float*)malloc(sizeof(float) * size);
        
        memset(cachedFloatArrs, 0, sizeof(float) * size);
    }
        
    // Move down the array to zero in at a particular point
    magnitudeArr += startIndex;
    
    if (!initialized && count == 10) {
        memcpy(cachedFloatArrs, magnitudeArr, sizeof(float) * size);
        
        [self toDecibles:cachedFloatArrs withSize:size];
        
        initialized = true;
    }
    
    if (!initialized) {
        return NotMoving;
    }
    
    if (sFrequency != currentFrequency) {
        if (catchUp++ == 10) {
            memcpy(cachedFloatArrs, magnitudeArr, sizeof(float) * size);
            
            [self toDecibles:cachedFloatArrs withSize:size];
            
            // Intialized, should already be true.
            
            catchUp = 0;
            
            count = 0;
            
            sFrequency = currentFrequency;
        }
    }
    
    [self toDecibles:magnitudeArr withSize:size];
    *arrayToUpdate = magnitudeArr;
    
    for (size_t index = 0; index < size; ++index) {
        magnitudeArr[index] -= (cachedFloatArrs)[index];
    }
    
    float leftMax = -1000.0;
    
    for (size_t index = 0; index < frequencyIndex - startIndex; ++index) {
        if (magnitudeArr[index] > leftMax) {
            leftMax = magnitudeArr[index];
        }
    }
    
    float rightMax = -1000.0;
    
    for (size_t index = frequencyIndex - startIndex + 1; index < size; ++index) {
        if (magnitudeArr[index] > rightMax) {
            rightMax = magnitudeArr[index];
        }
    }
    
    if (count > 9 && count < 30) {
        leftBaseLine += leftMax;
        rightBaseLine += rightMax;
    }
    
    if (count == 60) {
        leftBaseLine /= 20;
        rightBaseLine /= 20;
    }
    
    if (count >= 30) {
        NSLog(@"Left BaseLine: %f Left Max: %f", leftBaseLine, leftMax);
        NSLog(@"Right BaseLine: %f Right Max: %f", rightBaseLine, rightMax);
        
        if (rightMax > rightBaseLine * 1.3) {
            return MovingTowards;
        } else if (leftMax > leftBaseLine * 1.2) {
            return MovingAway;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.graphHelper->tearDownGL();
    delete self.graphHelper;
    self.graphHelper = nil;
    self.child = (ZoomMapViewController *)[segue destinationViewController];

}

- (void)keepPlayingAudio
{
    if (![self.audioManager playing]) {
        [self.audioManager play];
    }
}

- (void)zoomMap
{
    int random = arc4random() % 3;
    [self.child motionReqanizer:random];
}

@end
