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

@interface CompanyProfileViewController () <UIScrollViewDelegate, NSURLConnectionDelegate>

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

@property (strong, nonatomic) Stock *companyStock;

@end

@implementation CompanyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Company";
    [self setupScrollView];
}

- (void)setupScrollView
{
    self.companyScrollView.delegate = self;
    self.companyScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 700.f);
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
    
    self.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>
    
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
}


- (void)getGraphData
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:<#(NSString *)#> bundle:<#(NSBundle *)#>];
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
