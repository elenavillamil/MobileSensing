//
//  CompanyProfileViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 1/28/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "CompanyProfileViewController.h"
#import "Stock.h"
#import <JBChartView/JBLineChartView.h>
#import <JBLineChartView.h>
#import "Graph.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"

@interface CompanyProfileViewController () <UIScrollViewDelegate, UIAlertViewDelegate, GraphDelegate, JBLineChartViewDataSource, JBLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *companyIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *percentChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet JBLineChartView *graphView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *buySellSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *companyScrollView;
@property (weak, nonatomic) IBOutlet UISlider *stockAmountSlider;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *stopDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIScrollView *graphScrollView;
@property (weak, nonatomic) IBOutlet UILabel *stockAmountSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;


@property (strong,nonatomic) UIImageView *imageView;
@property (strong, nonatomic) Stock *companyStock;
@property (strong,nonatomic) Graph *graphData;
@property (strong,nonatomic) NSString *amaountSelectedBase;
@property (nonatomic) NSInteger amountToBuySell;
@property (nonatomic,strong) User *user;
@property (nonatomic, strong) UIActivityIndicatorView *loading;

@end

@implementation CompanyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Company";
    [self setupScrollView];
    
    self.graphData = [Graph sharedInstance];
    self.graphData.delegate = self;
    [self.graphData getStockGraphData];
    self.graphView.hidden = YES;
    self.amaountSelectedBase = @"Buy: %d";
    self.amountToBuySell = 0;
    
    [self showLoading];
}

- (void)showLoading
{
    self.loading =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.loading.center = self.view.center;
    
    [self.loading startAnimating];
    
    [self.view addSubview:self.loading];
}

- (void)setupScrollView
{
    self.companyScrollView.delegate = self;
    self.companyScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 700.f);
}

- (void)setupGraphScrollView
{
    self.graphScrollView.delegate = self;
    self.graphScrollView.contentSize = CGSizeMake(500.f, 272.f);
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.companyScrollView addGestureRecognizer:twoFingerTapRecognizer];
    [self centerScrollViewContents];
    [self setZoom];
}

- (void)setZoom
{
    CGRect scrollViewFrame = self.graphScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.graphScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.graphScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.graphScrollView.minimumZoomScale = minScale;
    
    self.graphScrollView.maximumZoomScale = 1.0f;
    self.graphScrollView.zoomScale = minScale;
    
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.graphScrollView.bounds.size;
    CGRect contentsFrame = self.graphView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.graphView.frame = contentsFrame;
}

- (void)setStock:(Stock *)stock
{
    self.companyStock = stock;
}


- (Stock *)companyStock
{
    if (!_companyStock) {
        _companyStock = [[Stock alloc] init];
    }
    
    return _companyStock;
}

- (void)setupCompanyData
{
    self.title = self.companyStock.stockName;
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f", self.companyStock.stockPrice];
    self.percentChangeLabel.text = [NSString stringWithFormat:@"%f%%", self.companyStock.percentChange];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)confirmButtonPressed:(id)sender {
    if (self.buySellSegmentedControl.selectedSegmentIndex == 0) {
        [self buyStock];
    } else {
        [self sellStock];
    }
}



- (void)getGraphData
{
//    UIStoryboard *story = [UIStoryboard storyboardWithName:(NSString *) bundle:<#(NSBundle *)#>];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - GraphDelegate
- (void)finishedLoading
{
    
    NSString *change = [self.graphData getCurrentPrice];
    self.percentChangeLabel.text = change;
    
    self.graphView.dataSource = self;
    self.graphView.delegate = self;
    [self.loading stopAnimating];

    [self setGraphViewFooter];
    [self setupGraphScrollView];
    self.graphView.hidden = NO;
    [self.graphView reloadData];
    
//    UIImage *graphImage = [self imageWithView:self.graphView];
//    
//    self.imageView = [[UIImageView alloc] initWithImage:graphImage];
//    [self.graphScrollView addSubview:self.imageView];
//    self.graphView.hidden = YES;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)failedToLoad
{
    //failed to get CSV file.... show alert view
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Stock" message:@"Quandl is having issues try again?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [self.loading stopAnimating];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.graphData getStockGraphData];
            break;
            
        default:
            break;
    }
}

- (void)setGraphViewFooter
{
    
}

#pragma mark - Buy/Sell

- (IBAction)changeSliderValue:(id)sender {
    NSInteger min = [self.minValueLabel.text integerValue];
    NSInteger max = [self.maxValueLabel.text integerValue];
    self.amountToBuySell = (max - min) * self.stockAmountSlider.value;
    
    self.stockAmountSelectedLabel.text = [NSString stringWithFormat:self.amaountSelectedBase, (long)self.amountToBuySell];
}

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    switch (self.buySellSegmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self setToBuy];
            break;
        case 1:
            [self setToSell];
        default: 
            break; 
    }
}

- (void)setToBuy
{
    self.amaountSelectedBase = @"Buy: %d";
    self.stockAmountSelectedLabel.text = @"Buy: ";
    
}

- (void)setToSell
{
    self.amaountSelectedBase = @"Sell: %d";
    self.stockAmountSelectedLabel.text = @"Sell: ";
    
//    self.maxValueLabel.text = [self.user getAmountOwnForStock:(self.companyStock)];
}

- (void)buyStock
{
    // connect to api and backend
}

- (void)sellStock
{
    // connect to api and backend
}

- (IBAction)saveToFavorites:(id)sender {
}

#pragma mark - Zoom methods

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.graphScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.graphScrollView.minimumZoomScale);
    [self.graphScrollView setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    CGFloat newZoomScale = self.graphScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.graphScrollView.maximumZoomScale);
    CGSize scrollViewSize = self.graphScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.graphScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    if ([scrollView isEqual:self.graphScrollView]) {
        return self.graphView;
    }
    return nil;
}

#pragma mark - JBGraphDelegate

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return 99; // number of values for a line
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [self.graphData getValueAt:(99-horizontalIndex-1)]; // y-position (y-axis) of point at horizontalIndex (x-axis)
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    // Update view
    self.percentChangeLabel.text = [NSString stringWithFormat:@"%.02f",[self.graphData getValueAt:horizontalIndex]];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    // Update view
    NSString *change = [self.graphData getCurrentPrice];
    self.percentChangeLabel.text = change;
}


@end
