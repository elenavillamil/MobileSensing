//
//  ViewController.swift
//  LookinLive
//
//  Created by Eric Larson on 2/26/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var flashSlider: UISlider!
    var videoManager : VideoAnalgesic! = nil
    let filter :CIFilter = CIFilter(name: "CIColorMonochrome")
    var countLeftEye = 0
    var countRightEye = 0
    
    @IBAction func panRecognized(sender: AnyObject) {
        let point = sender.translationInView(self.view)
        
        var swappedPoint = CGPoint()
        
        // convert coordinates from UIKit to core image
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(-1.0, 1.0))
        transform = CGAffineTransformTranslate(transform, self.view.bounds.size.width/2,
            self.view.bounds.size.height/2)
        
        swappedPoint = CGPointApplyAffineTransform(point, transform);
        
        //        filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //CIDetectorTracking:,CIDetectorMinFeatureSize:
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
        
        let yellowColor = CIColor(red: 255.0, green: 255.0, blue: 0.0)
        let blueColor = CIColor(red: 0.0, green: 0.0, blue: 255.0)
        let redColor = CIColor(red: 255.0, green: 0.0, blue: 0.0)
        
        self.filter.setValue(yellowColor, forKey: "inputColor")
        
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace,
            context: self.videoManager.getCIContext(),
            options: optsDetector)
        
        //var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        
        var overlayFilter :CIFilter = CIFilter(name: "CISourceOverCompositing")
        var noirFilter :CIFilter = CIFilter(name: "CIPhotoEffectNoir")
        var invertFilter :CIFilter = CIFilter(name: "CIColorInvert")
        var bloomFilter :CIFilter = CIFilter(name: "CIBloom")
        
        self.videoManager.setProcessingBlock( { (var imageInput) -> (CIImage) in
            
            var orientation = UIApplication.sharedApplication().statusBarOrientation
            
            if (self.videoManager.getCapturePosition() == AVCaptureDevicePosition.Back)
            {
                if (orientation == UIInterfaceOrientation.LandscapeLeft)
                {
                    orientation = UIInterfaceOrientation.LandscapeRight
                }
                else if (orientation == UIInterfaceOrientation.LandscapeRight)
                {
                    orientation = UIInterfaceOrientation.LandscapeLeft
                }
            }
            
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(orientation), CIDetectorSmile: true, CIDetectorEyeBlink : true]
            
            var features = detector.featuresInImage(imageInput, options: optsFace)
            
            var swappedPoint = CGPoint()
            
            var tmpImage = imageInput
            var croppedImage :CIImage
            
            for f in features as [CIFaceFeature] {
                
                // Face
                croppedImage = tmpImage.imageByCroppingToRect(f.bounds)
                
                self.filter.setValue(croppedImage, forKey: "inputImage")
                self.filter.setValue(yellowColor, forKey: "inputColor")
                
                croppedImage = self.filter.outputImage
                
                overlayFilter.setValue(croppedImage, forKey: "inputImage")
                overlayFilter.setValue(tmpImage, forKey: "inputBackgroundImage")
                
                tmpImage = overlayFilter.outputImage
                
                
                var mouthOrigin:CGPoint
                var leftEyeOrigin:CGPoint
                var rightEyeOrigin:CGPoint
                
                var mouthRectangle:CGRect
                var leftEyeRectangle:CGRect
                var rightEyeRectangle:CGRect
                
                
                if (f.hasMouthPosition && f.hasLeftEyePosition && f.hasRightEyePosition)
                {
                    
                    /*
                    mouthOrigin = CGPoint(x: f.mouthPosition.x - 10, y: f.mouthPosition.y - 40)
                    leftEyeOrigin = CGPoint(x: f.leftEyePosition.x - 10.0, y: f.leftEyePosition.y - 20)
                    rightEyeOrigin = CGPoint(x: f.rightEyePosition.x - 10.0, y: f.rightEyePosition.y - 20)
                    
                    mouthRectangle = CGRect(origin: mouthOrigin, size: CGSize(width: 20.0, height: 80.0))
                    leftEyeRectangle = CGRect(origin: leftEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                    rightEyeRectangle = CGRect(origin: rightEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                    */
                    
                    
                    if (orientation.isPortrait)
                    {
                        mouthOrigin = CGPoint(x: f.mouthPosition.x - 10, y: f.mouthPosition.y - 40)
                        leftEyeOrigin = CGPoint(x: f.leftEyePosition.x - 10.0, y: f.leftEyePosition.y - 20)
                        rightEyeOrigin = CGPoint(x: f.rightEyePosition.x - 10.0, y: f.rightEyePosition.y - 20)
                        
                        mouthRectangle = CGRect(origin: mouthOrigin, size: CGSize(width: 20.0, height: 80.0))
                        leftEyeRectangle = CGRect(origin: leftEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                        rightEyeRectangle = CGRect(origin: rightEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                    }
                        
                    else
                    {
                        mouthOrigin = CGPoint(x: f.mouthPosition.x - 40, y: f.mouthPosition.y - 10)
                        
                        leftEyeOrigin = CGPoint(x: f.leftEyePosition.x - 20.0, y: f.leftEyePosition.y - 10)
                        rightEyeOrigin = CGPoint(x: f.rightEyePosition.x - 20.0, y: f.rightEyePosition.y - 10)
                        
                        mouthRectangle = CGRect(origin: mouthOrigin, size: CGSize(width: 80.0, height: 20.0))
                        leftEyeRectangle = CGRect(origin: leftEyeOrigin, size: CGSize(width: 40.0, height: 20.0))
                        rightEyeRectangle = CGRect(origin: rightEyeOrigin, size: CGSize(width: 40.0, height: 20.0))
                    }
                    
                    
                    // Mouth
                    var newOverlayFilter :CIFilter = CIFilter(name: "CISourceOverCompositing")
                    
                    croppedImage = imageInput.imageByCroppingToRect(mouthRectangle)
                    
                    self.filter.setValue(croppedImage, forKey: "inputImage")
                    self.filter.setValue(blueColor, forKey: "inputColor")
                    
                    croppedImage = self.filter.outputImage
                    
                    newOverlayFilter.setValue(croppedImage, forKey: "inputImage")
                    newOverlayFilter.setValue(tmpImage, forKey: "inputBackgroundImage")
                    
                    tmpImage = newOverlayFilter.outputImage
                    
                    // Left Eye
                    croppedImage = imageInput.imageByCroppingToRect(leftEyeRectangle)
                    
                    self.filter.setValue(croppedImage, forKey: "inputImage")
                    self.filter.setValue(redColor, forKey: "inputColor")
                    
                    croppedImage = self.filter.outputImage
                    
                    newOverlayFilter.setValue(croppedImage, forKey: "inputImage")
                    newOverlayFilter.setValue(tmpImage, forKey: "inputBackgroundImage")
                    
                    tmpImage = newOverlayFilter.outputImage
                    
                    // Right Eye
                    croppedImage = imageInput.imageByCroppingToRect(rightEyeRectangle)
                    
                    self.filter.setValue(croppedImage, forKey: "inputImage")
                    self.filter.setValue(redColor, forKey: "inputColor")
                    
                    croppedImage = self.filter.outputImage
                    
                    newOverlayFilter.setValue(croppedImage, forKey: "inputImage")
                    newOverlayFilter.setValue(tmpImage, forKey: "inputBackgroundImage")
                    
                    tmpImage = newOverlayFilter.outputImage
                    
                    NSLog(f.hasSmile ? "Yes" : "No");
                    
                    if(f.hasSmile)
                    {
                        noirFilter.setValue(tmpImage, forKey: "inputImage")
                        tmpImage = noirFilter.outputImage
                    }
                    
                    if (f.leftEyeClosed)
                    {
                        self.countLeftEye += 1
                        
                        if (self.countLeftEye > 2)
                        {
                            invertFilter.setValue(tmpImage, forKey: "inputImage")
                            tmpImage = invertFilter.outputImage

                        }
                    }
                    else
                    {
                        self.countLeftEye = 0
                    }
                    
                    if(f.rightEyeClosed)
                    {
                        self.countRightEye += 1
                        
                        if (self.countRightEye > 2)
                        {
                            bloomFilter.setValue(2.0, forKey: "inputIntensity")
                            bloomFilter.setValue(tmpImage, forKey: "inputImage")
                            tmpImage = bloomFilter.outputImage
                        }
                    }
                    else
                    {
                        self.countRightEye = 0
                    }
                    
                }
            }
            
            return tmpImage;
        })
        
        self.videoManager.start()
    }
    
    @IBAction func flash(sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.flashSlider.value = 1.0
        }
        else{
            self.flashSlider.value = 0.0
        }
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }
    
    @IBAction func setFlashLevel(sender: UISlider) {
        if(sender.value>0.0){
            self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }
}

