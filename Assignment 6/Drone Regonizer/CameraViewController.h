//
//  CameraViewController.h
//  Drone Regonizer
//
//  Created by Tyler Hargett on 4/15/15.
//  Copyright (c) 2015 Tyler Hargett. All rights reserved.
//

#import "ViewController.h"

@protocol PictureDelegate <NSObject>

- (void)addTargetPhoto:(UIImage *)photo;

@end

@interface CameraViewController : ViewController <PictureDelegate>{
    id <PictureDelegate> delegate;
}

@property (retain) id <PictureDelegate> delegate;

@end
