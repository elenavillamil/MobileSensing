//
//  RootViewController.m
//  PlayRollingStones
//
//  Created by Elena Villamil on 2/11/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ModuleBViewController.h"
#import "Novocaine.h"

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
    
    self.novocaine = [Novocaine audioManager];
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

- (IBAction)onSliderChange:(id)sender {
    self.currentSoundPlayFrequence = self.frequenceValueSlider.value;
    
    self.frequenceValueLabel.text = [NSString stringWithFormat:@"%.2f", self.currentSoundPlayFrequence];
}
@end
