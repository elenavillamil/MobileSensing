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

@interface PulseViewController ()

@property (nonatomic) GraphHelper* graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@end

@implementation PulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];

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
    const size_t windowSize = 30;
    float* data = (float*)malloc(sizeof(float) * 300);
    
    for (int i = 1; i < 300; i++)
    {
        float x = float(i);
        if (x > 150) {
            x -= (x-150);
        }
        
        data[i] = x+100;
    }
    
    
    self.graphHelper->setGraphData(0, data, windowSize, 0);
    self.graphHelper->update();
    free(data);
    data = nil;

}

-(void)dealloc {
    self.graphHelper->tearDownGL();


    delete self.graphHelper;

    self.graphHelper = nil;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}


@end
