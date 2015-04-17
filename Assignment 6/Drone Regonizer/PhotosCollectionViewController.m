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
#import <AVFoundation/AVFoundation.h>

@interface PhotosCollectionViewController () <PictureDelegate, NSURLSessionTaskDelegate>

@property (strong,nonatomic) NSURLSession *session;
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"ImageCollectionViewCell";
static NSString * const kURL = @"http://Elenas-MacBook-Pro.local:8888/";
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
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10.0);
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
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
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImage *picture = (UIImage *)[self.photos objectAtIndex:indexPath.row];
    UIImage *resizedImage = [self imageWithImage:picture scaledToSize:CGSizeMake(128, 128)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
    [imageView setFrame:CGRectMake(8, 8, 128.f, 128.f)];
    [cell addSubview:imageView];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
     UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
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

#pragma mark - Camera and Image

- (IBAction)sendRequest:(id)sender {
    
    NSNumber *index = [NSNumber numberWithInteger:1];
    NSNumber *numberOfPhotos = [NSNumber numberWithInteger:self.photos.count];
    int count = 1;
    
    
    for (UIImage *picture in self.photos) {
        
        if ([index integerValue]> 2) return;
        NSURL *postURL = [NSURL URLWithString:kURL];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
        [request setHTTPMethod:@"POST"];
        request.timeoutInterval = 40.0;

        NSString *imageString =[UIImagePNGRepresentation(picture) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSDictionary *dict;
        
        if (count < numberOfPhotos.intValue)
        {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:imageString, @"image", @"Elena", @"name", @"false", @"last", nil];
        }
        else
        {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:imageString, @"image", @"Elena", @"name", @"true", @"last", nil];
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
                                  NSLog(@"Upload error: %@", error);
                              }
                          }];
        [uploadTask resume];
                                 
        int value = [index intValue];
        index = [NSNumber numberWithInt:value + 1];
        
        
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

-(void)generateImage
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }

        UIImage *image = [UIImage imageWithCGImage:im];
        UIImage * portraitImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationLeft];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photos addObject:portraitImage];
            [self.collectionView reloadData];
        });
    
        
    };
    
    CGSize maxSize = CGSizeMake(320, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
}

- (void)getAllImages {
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
    
    [self.collectionView reloadData];
}

- (void)addPhoto:(NSNotification *)notification {
    NSLog(@"%@", notification);
}

- (BOOL)addTargetPhoto:(UIImage *)photo {
    [self.photos addObject:photo];
    NSLog(@"number of photos: %lu", (unsigned long)self.photos.count);
    
    return YES;
}

@end
