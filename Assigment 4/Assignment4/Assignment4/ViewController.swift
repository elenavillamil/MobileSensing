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
        //filter.setValue(75, forKey: "inputRadius")
        
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace,
            context: self.videoManager.getCIContext(),
            options: optsDetector)
        
        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        
        self.videoManager.setProcessingBlock( { (var imageInput) -> (CIImage) in
            
            var features = detector.featuresInImage(imageInput, options: optsFace)
            var swappedPoint = CGPoint()
            
            let overlayFilter :CIFilter = CIFilter(name: "CISourceOverCompositing")
            
            for f in features as [CIFaceFeature]{
                
                let applyFilterToRectangle = { (rectangle:CGRect, color:CIColor) -> Void in
                    var croppedImage = imageInput.imageByCroppingToRect(rectangle)
                    
                    self.filter.setValue(croppedImage, forKey: "inputImage")
                    self.filter.setValue(color, forKey: "inputColor")
                    
                    croppedImage = self.filter.outputImage
                    
                    overlayFilter.setValue(croppedImage, forKey: "inputImage")
                    overlayFilter.setValue(imageInput, forKey: "inputBackgroundImage")
                    
                    imageInput = overlayFilter.outputImage
                    
                }
                
                applyFilterToRectangle(f.bounds, yellowColor)
                
                let origin = CGPoint(x: f.mouthPosition.x - 10, y: f.mouthPosition.y - 40)
                
                var mouthRectangle = CGRect(origin: origin, size: CGSize(width: 20.0, height: 80.0))
                applyFilterToRectangle(mouthRectangle, blueColor)
                
                let leftEyeOrigin = CGPoint(x: f.leftEyePosition.x - 10.0, y: f.leftEyePosition.y - 20)
                var leftEyeRectangle = CGRect(origin: leftEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                
                applyFilterToRectangle(leftEyeRectangle, redColor)
                
                let rightEyeOrigin = CGPoint(x: f.rightEyePosition.x - 10.0, y: f.rightEyePosition.y - 20)
                var rightEyeRectangle = CGRect(origin: rightEyeOrigin, size: CGSize(width: 20.0, height: 40.0))
                
                applyFilterToRectangle(rightEyeRectangle, redColor)
                
            }
            
            if (overlayFilter.outputImage != nil)
            {
                return overlayFilter.outputImage
            }
                
            else
            {
                return imageInput;
            }
            
            
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
