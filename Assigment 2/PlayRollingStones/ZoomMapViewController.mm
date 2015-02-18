//
//  ZoomMapViewController.m
//  PlayRollingStones
//
//  Created by Tyler Hargett on 2/18/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ZoomMapViewController.h"
#import <MapKit/MapKit.h>

@interface ZoomMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ZoomMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
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
- (IBAction)zoomTest:(id)sender {
    [self zoomMap:self.mapView byDelta:.5f];
}

#pragma mark - MapKit Delegate

- (void)zoomMap:(MKMapView*)mapView byDelta:(float) delta {
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = mapView.region.span;
    span.latitudeDelta*=delta;
    span.longitudeDelta*=delta;
    
    if (span.latitudeDelta > 180 || span.longitudeDelta > 180) {
        span.latitudeDelta = 180;
        span.longitudeDelta = 180;
    } else if (span.latitudeDelta < 0 || span.longitudeDelta < 0)
    {
        span.latitudeDelta = 0;
        span.longitudeDelta = 0;
    }
    
    region = [mapView regionThatFits:region];
    region.span=span;
    [mapView setRegion:region animated:YES];
    
}

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end