//
//  RootViewController.m
//  PlayRollingStones
//
//  Created by Elena Villamil on 2/11/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ModuleBViewController.h"
#import "Novocaine.h"

#define AVERAGE_SIZE 5
#define SAMPLE_AMOUNT 4096

@interface ModuleBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *frequenceValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *frequenceValueSlider;
@property double currentSoundPlayFrequence;
@property (weak, nonatomic) Novocaine* novocaine;
@end

@implementation ModuleBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
