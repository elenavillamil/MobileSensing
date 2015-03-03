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
    let twentyFourHours = 24 * 3600 as NSTimeInterval

    @IBOutlet weak var yesterdayStepsLabel: UILabel!
    @IBOutlet weak var todayStepsLabel: UILabel!
    @IBOutlet weak var stepsToGoalLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchMotionActivityData()
        
        fetchPedometerData()
    }
    
    func fetchPedometerData() {
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startPedometerUpdatesFromDate(NSDate()) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    self.todayStepsLabel.text = NSString(format: "%d", pedData.numberOfSteps)
                    
                    // add accessor to steps in goal in settings
                    // self.stepsToGoLabel.text = *goalSteps - pedData.numberOfSteps
                }
            }
            
            //MAY BE ILLEGAL -- ASK ELENA
            self.pedometer.startPedometerUpdatesFromDate(NSDate(timeIntervalSinceNow: -twentyFourHours)) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    self.todayStepsLabel.text = NSString(format: "%d", pedData.numberOfSteps)
                }
            }
        }
    }

    
    func fetchMotionActivityData()
    {
        if CMMotionActivityManager.isActivityAvailable()
        {
        
            self.activityManager.startActivityUpdatesToQueue(self.customQueue){
                (activity:CMMotionActivity!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    self.currentActivityLabel.text = activity.description
                }
            }
            
            // Prepare activity updates
            activityManager.startActivityUpdatesToQueue(self.customQueue) {
                data in
                dispatch_async(dispatch_get_main_queue()) {
                    if data.running {
                        //self.activityImageView.image = UIImage(named: "run")
                        self.currentActivityLabel.text = "Running"
                    } else if data.cycling {
                        //self.activityImageView.image = UIImage(named: "cycle")
                        self.currentActivityLabel.text = "Cycling"
                    } else if data.walking {
                        //self.activityImageView.image = UIImage(named: "walk")
                        self.currentActivityLabel.text = "Walking"
                    } else if data.walking {
                        //self.activityImageView.image = UIImage(named: "nil")
                        self.currentActivityLabel.text = "Still"
                    } else if data.walking {
                        //self.activityImageView.image = UIImage(named: "nil")
                        self.currentActivityLabel.text = "Driving"
                    } else {
                        //self.activityImageView.image = nil
                        self.currentActivityLabel.text = "Stationary"
                    }
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

