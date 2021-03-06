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
#import "MBProgressHUD.h"
#import "HeaderCollectionReusableView.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotosCollectionViewController () <PictureDelegate,TargetNameDelegate, NSURLSessionTaskDelegate>

@property (strong,nonatomic) NSURLSession *session;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSString *targetName;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"ImageCollectionViewCell";
static NSString * const kURL = @"http://104.150.120.136:8888/";
//static NSString *const kURLRemove = @"http://www.ev7n.com:8888/remove";
static NSString *const kURLRemove = @"http://104.150.120.136:8888/remove";

static int FPS = 30;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Do any additional setup after loading the view.
    self.tabBarController.title = @"Target";
    
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
    self.tabBarController.navigationItem.rightBarButtonItem = cameraButton;
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 10, 50, 10);
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
    self.tabBarController.navigationItem.rightBarButtonItem = cameraButton;
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
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.photos.count;
    NSLog(@"number of photos: %ld", (long)count);
    if (count > 20) {
        return 20;
    }
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CGFloat height = cell.frame.size.height - 10;
    CGFloat width = cell.frame.size.width - 10;
    
    
    UIImage *picture = (UIImage *)[self.photos objectAtIndex:indexPath.row];
    UIImage *resizedImage = [self imageWithImage:picture scaledToSize:CGSizeMake(width, height)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
    [imageView setFrame:CGRectMake(5, 5, width, height)];
    [cell addSubview:imageView];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HeaderCollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    reusableview.backgroundColor = [UIColor whiteColor];
    reusableview.delegate = self;
    return reusableview;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

- (void)alertMessageForNoName {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No name entered"
                                                                   message:@"Please enter a target's name to track"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertMessageForConnectionFailure:(NSError *)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Connection Error"
                                                                   message:[NSString stringWithFormat:@"%@", error]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Camera and Image

- (void)sendDeleteRequest {
    NSURL *postURL = [NSURL URLWithString:kURLRemove];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
    [request setHTTPMethod:@"POST"];
    request.timeoutInterval = 30.0;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"remove", @"all", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:request
                                                              fromData:postData
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         
                                                         if (error) {
                                                             dispatch_async (dispatch_get_main_queue(), ^{
                                                             [self alertMessageForConnectionFailure:error];
                                                             });
                                                         } else {
                                                             
                                                             if (data) {
                                                                 
                                                                 dispatch_async (dispatch_get_main_queue(), ^{
                                                                     NSLog(@"Response: %@ \n Data: %@", response, data);
                                                                    [self sendPhotos];
                                                                 });
                                                             }
                                                             
//                                                             NSError *jsonError;
//                                                             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
//                                                                                                                      options:0
//                                                                                                                        error:&jsonError];
//                                                             
//                                                             
//                                                             if (jsonError) {
//                                                                 dispatch_async (dispatch_get_main_queue(), ^{
//                                                                     [self alertMessageForConnectionFailure:jsonError];
//                                                                 });
//                                                             } else {
//                                                                 if ([[response objectForKey:@"arg1"] isEqualToString:@"OK"]) {
//                                                                  [self sendPhotos];
//                                                                 }
//                                                             }
                                                             
                                                             
                                                         }
                                                     }];
    [task resume];
    
}

- (void)sendPhotos {
    NSNumber *index = [NSNumber numberWithInteger:1];
    NSNumber *numberOfPhotos = [NSNumber numberWithInteger:self.photos.count];
    int count = 0;
    
    
    for (UIImage *picture in self.photos) {
        int max = 25;
        
        if ([index integerValue]> max) return;
        
        NSURL *postURL = [NSURL URLWithString:kURL];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
        [request setHTTPMethod:@"POST"];
        request.timeoutInterval = 40.0;
        
        
        //rotates image properly to allow png to be proper direction
        UIImage *rotatedImage = nil;
        
        if(!(picture.imageOrientation == UIImageOrientationUp ||
             picture.imageOrientation == UIImageOrientationUpMirrored))
        {
            CGSize imgsize = picture.size;
            UIGraphicsBeginImageContext(imgsize);
            [picture drawInRect:CGRectMake(0.0, 0.0, imgsize.width, imgsize.height)];
            rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        //converts image to string value
        NSString *imageString;
        if (rotatedImage != nil) {
            imageString =[UIImagePNGRepresentation(rotatedImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        } else {
            imageString =[UIImagePNGRepresentation(picture) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        
        NSDictionary *dict;
        
        count += 1;
        
        if (count >= numberOfPhotos.intValue || count >= max)
        {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:imageString, @"image", self.targetName, @"name", [[NSNumber alloc] initWithInt:count], @"count", @"true", @"last", nil];
        }
        else
        {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:imageString, @"image", self.targetName, @"name", [[NSNumber alloc] initWithInt:count], @"count", @"false", @"last", nil];
        }
        
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
                                  [self alertMessageForConnectionFailure:error];
                              }
                          }];
        [uploadTask resume];
        
        int value = [index intValue];
        index = [NSNumber numberWithInt:value + 1];
        
        
    }
}

- (IBAction)sendRequest:(id)sender {
    
    if (self.targetName == nil) {
        [self alertMessageForNoName];
        return;
    } else {
        [self sendDeleteRequest];
    }
    
}

- (void)showCamera:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.videoURL = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.videoController = [[MPMoviePlayerController alloc] init];
    
    [self.videoController setContentURL:self.videoURL];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"Converting to Images";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        [self getAllImages];
    } completionBlock:^{
        [hud removeFromSuperview];
        [self.collectionView reloadData];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.collectionView reloadData];
}

- (void)getAllImages {
    [self.photos removeAllObjects];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    for (Float64 i = 0; i < CMTimeGetSeconds(asset.duration) *  FPS ; i++){
        @autoreleasepool {
            CMTime time = CMTimeMake(i, FPS);
            NSError *err;
            CMTime actualTime;
            CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&err];
            UIImage *generatedImage = [[UIImage alloc] initWithCGImage:image];
            UIImage * portraitImage = [[UIImage alloc] initWithCGImage: generatedImage.CGImage
                                                                 scale: 1.0
                                                           orientation: UIImageOrientationRight];
            [self.photos addObject:portraitImage];
            CGImageRelease(image);
        }
    }
    
}

- (void)addPhoto:(NSNotification *)notification {
    NSLog(@"%@", notification);
}

- (BOOL)addTargetPhoto:(UIImage *)photo {
    [self.photos addObject:photo];
    NSLog(@"number of photos: %lu", (unsigned long)self.photos.count);
    
    return YES;
}

#pragma mark - TargetNameDelegate

- (void)setName:(NSString *)name {
    self.targetName = name;
}

@end
