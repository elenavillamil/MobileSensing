//
//  ViewController.swift
//  Step Counter
//
//  Created by Elena Villamil on 2/22/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {

    
    let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    let pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdatesToQueue( self.customQueue)
                { (activity:CMMotionActivity!) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue())
                        {
                            self.textLabel.text = activity.description
                    }
            }
        }
        
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startPedometerUpdatesFromDate(NSDate()) { (pedData: CMPedometerData!, error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        self.textLabelLower.text = pedData.description
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playGame(sender: AnyObject) {
        if (true) {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController

            self.navigationController?.pushViewController(secondViewController, animated:true)
        }
    }

}

