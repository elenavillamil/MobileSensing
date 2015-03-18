//
//  PulseViewController.m
//  Assignment4
//
//  Created by Tyler Hargett on 3/17/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

#import "PulseViewController.h"
#import "SMUGraphHelper.h"

@interface PulseViewController ()

@property (nonatomic) GraphHelper* graphHelper;

@end

@implementation PulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)updateGraph {
//        self.graphHelper->setGraphData(0, averagedArray == NULL ? self.fftMagnitudeBuffer : averagedArray, windowSize * .95, sqrt(SAMPLE_AMOUNT));
//        self.graphHelper->setGraphData(1, copyMagnitudeBuffer + startIndex, windowSize * .95, sqrt(SAMPLE_AMOUNT));
//        
//        self.graphHelper->update();

}

-(void)dealloc {
    self.graphHelper->tearDownGL();
    

    delete self.graphHelper;

    self.graphHelper = nil;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
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
