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
    let user = User.sharedInstance
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
        let now = NSDate()
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startPedometerUpdatesFromDate(now) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    
                    // Needs to add today's steps if the app start once the day has already started
                    let steps = pedData.numberOfSteps.integerValue
                    
                    // Set today steps
                    self.todayStepsLabel.text = NSString(format: "%d", steps)
                    
                    // Set steps to goal
                    if self.user.getGoal() - steps > 0
                    {
                        self.stepsToGoalLabel.text = NSString(format: "%d", self.user.getGoal() - steps)
                    }
                    else
                    {
                        self.stepsToGoalLabel.text = "Met!"
                        
                        if steps - self.user.getGoal() >= 100 && steps - self.user.getGoal() < 200 && !self.user.getExtraLifeOne()
                        {
                            self.user.setExtraLifeOne(true)
                            self.user.setLifes(self.user.getLifes() + 1)
                        }
                        
                        else if steps - self.user.getGoal() >= 200 && steps - self.user.getGoal() < 400 && !self.user.getExtraLifeTwo()
                        {
                            self.user.setExtraLifeTwo(true)
                            self.user.setLifes(self.user.getLifes() + 1)
                        }
                        
                        else if steps - self.user.getGoal() >= 400 && !self.user.getExtraLifeThree()
                        {
                            self.user.setExtraLifeThree(true)
                            self.user.setLifes(self.user.getLifes() + 1)
                        }
                    }
                }
            }
            
            let from = now.dateByAddingTimeInterval(-60*60*24)
            //NSCalendar
            //textField.resign first responder
            
            //Get yesterday steps
            self.pedometer.queryPedometerDataFromDate(from, toDate: now) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    self.yesterdayStepsLabel.text = NSString(format: "%d", pedData.numberOfSteps)
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

