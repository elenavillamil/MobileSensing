//
//  PhotosCollectionViewController.m
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/15/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "CameraViewController.h"
#import "ImageCollectionViewCell.h"
#import "LongCollectionViewCell.h"

@interface PhotosCollectionViewController () <PictureDelegate, NSURLSessionTaskDelegate>

@property (strong,nonatomic) NSURLSession *session;
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"ImageCollectionViewCell";
static NSString * const kURL = @"http://Elenas-MacBook-Pro.local:8888/";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[LongCollectionViewCell class] forCellWithReuseIdentifier:@"LongCollectionViewCell"];
    // Do any additional setup after loading the view.
    self.tabBarController.title = @"Target";
    
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
    self.tabBarController.navigationItem.rightBarButtonItem = cameraButton;
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)photos {
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0){
        return self.photos.count; }
    else return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return [self bottomSection:collectionView cellForIndexPath:indexPath];
    }
    
     ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *test = [[UIImageView alloc] initWithFrame:cell.frame];
    
    UIImage *picture = (UIImage *)[self.photos objectAtIndex:indexPath.row];
    [cell setImage:picture];
    test.image = picture;
    
    [cell addSubview:test];
//    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (UICollectionViewCell *)bottomSection: (UICollectionView *)collectionView cellForIndexPath:(NSIndexPath*) indexPath {
    LongCollectionViewCell *bottom = (LongCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"LongCollectionViewCell" forIndexPath:indexPath];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(sendRequest:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Send Request" forState:UIControlStateNormal];
    button.frame = CGRectMake(20.f, 20.f, 280.f, 40.f);
    [bottom addSubview:button];
    bottom.backgroundColor = [UIColor greenColor];
    return bottom;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (IBAction)sendRequest:(id)sender {
    
    NSNumber *index = [NSNumber numberWithInteger:1];
    NSNumber *numberOfPhotos = [NSNumber numberWithInteger:self.photos.count];
    for (UIImage *picture in self.photos) {
        NSURL *postURL = [NSURL URLWithString:kURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
        [request setHTTPMethod:@"POST"];
        NSData *imageData = UIImagePNGRepresentation(picture);
        NSString *imageString =[UIImagePNGRepresentation(picture) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

        
//        NSDictionary *jsonDic = [NSDictionary dictionaryWithObjects:@[numberOfPhotos,index,imageString] forKeys:@[@"number", @"index", @"picture"]];
        //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:numberOfPhotos, @"number", index, @"index", imageString, @"image", nil];
        
        //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Hola", @"arg1", @"Testing", @"arg2", nil];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:imageString, @"arg1", @"Elena", @"arg2", nil];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error) {
            break;
        }
        
        NSURLSessionUploadTask *uploadTask =
        [self.session uploadTaskWithRequest:request
                                   fromData:postData
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                              
                              if (error) {
                                  NSLog(@"Upload error: %@", error);
                              }
                          }];
        [uploadTask resume];
                                 
        int value = [index intValue];
        index = [NSNumber numberWithInt:value + 1];
    }
    
}

- (void)showCamera:(id)sender {
    CameraViewController *cameraVC = (CameraViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (void)addTargetPhoto:(UIImage *)photo {
    [self.photos addObject:photo];
}

@end
