//
//  SearchTableViewController.m
//  StockApp
//
//  Created by Tyler Hargett on 2/5/15.
//  Copyright (c) 2015 teamE1. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SearchTableViewCell.h"
#import "CompanyProfileViewController.h"
#import "Stock.h"

@interface SearchTableViewController () <NSURLConnectionDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSURLConnection *connection;

@end

static NSString * const baseURL = @"http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=";
static NSString * const endURL = @"&callback=YAHOO.Finance.SymbolSuggest.ssCallback";

static NSString * const test = @"http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=app&callback=YAHOO.Finance.SymbolSuggest.ssCallback";

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.searchResults removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Bar

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self searchForStock:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

- (void)searchForStock:(NSString *)name
{
    NSString *urlString = [[baseURL stringByAppendingString:name] stringByAppendingString:endURL];
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.connection != nil) {
        self.connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self startImmediately:YES];
    } else {
        self.connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self startImmediately:YES];
    }
}

#pragma mark - URL connection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error = nil;
    NSString* stringJSON = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSString * remove = [stringJSON stringByReplacingOccurrencesOfString:@"YAHOO.Finance.SymbolSuggest.ssCallback(" withString:@""];
    NSString * json =[remove stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        [self parseJSON:jsonArray];
    }
}

- (void)parseJSON:(NSDictionary *)jsonResponse
{
    NSDictionary* responses = (NSDictionary *)[jsonResponse objectForKey:@"ResultSet"];
    NSArray *results = [responses objectForKey:@"Result"];
    
   [self.searchResults removeAllObjects];
    
    for (NSDictionary  *company in results)
    {
        NSString *tradePlace = [company objectForKey:@"exchDisp"];
        if ([tradePlace isEqualToString:@"NASDAQ"]) {
            [self.searchResults addObject:company];
        }
    }

    //reload results
    [self.tableView reloadData];
}

- (NSMutableArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return _searchResults;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
    
    NSDictionary *cellStock = (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
    cell.companyNameLabel.text = [cellStock objectForKey:@"name"];
    cell.tickerLabel.text = [cellStock objectForKey:@"symbol"];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SearchTableViewCell *searchCell = (SearchTableViewCell *)sender;
    CompanyProfileViewController *profile = (CompanyProfileViewController *)[segue destinationViewController];
    Stock *stock = [[Stock alloc] init];
    [profile setStock:stock];
}


@end
