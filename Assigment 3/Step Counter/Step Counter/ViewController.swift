//
//  ViewController.swift
//  Step Counter
//
//  Created by Elena Villamil on 2/22/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation


class ViewController: UIViewController, UIAlertViewDelegate{
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchPedometerData()
    }
    
    func fetchPedometerData() {
        // Get current time when the app starts
        var now = NSDate()
    
        var startSteps = 0
        
        // Get day, month, year and time of that current time
        let gregorianCalendar = NSCalendar(calendarIdentifier:NSGregorianCalendar)

        let flags:NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit
        let components = gregorianCalendar?.components(flags, fromDate: now)
        
        // Check if today is the same day save in defualt, for the extra lifes
        let day = components!.day
        if (day != self.user.getLastDay())
        {
            self.user.setLastDay(day)
            self.user.resetWhenNewDay()
        }
        
        // Getting the hour so we can get a new NSDate starting at 00:00 am of current date
        let hour: Int = components!.hour
        let minute: Int = components!.minute
        let second: Int = components!.second
        
        let subtraction = (Double)(hour * (-60) * 60 - minute * 60 - second)
        
        let fromStartToday = now.dateByAddingTimeInterval(subtraction)

        // Check if pedometer is available
        if CMPedometer.isStepCountingAvailable(){
            
            //Get today steps up to now
            self.pedometer.queryPedometerDataFromDate(fromStartToday, toDate: now) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in
                startSteps = pedData.numberOfSteps.integerValue
                dispatch_async(dispatch_get_main_queue()) {
                    self.todayStepsLabel.text = NSString(format: "%d", startSteps)
                    self.setGoalLabel(startSteps)
                }
            }
            
            // Start the updates
            self.pedometer.startPedometerUpdatesFromDate(now) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    
                    // Needs to add today's steps if the app start once the day has already started
                    let steps = startSteps + pedData.numberOfSteps.integerValue
                    
                    // Set today steps
                    self.todayStepsLabel.text = NSString(format: "%d", steps)
                    // Set steps to goal
                    self.setGoalLabel(steps)
                }
            }
            
            // Substract 24 hours from 00:00am of today to get a NSDate of yesterday at 00:00
            let fromStartYesterday = fromStartToday.dateByAddingTimeInterval(-60*60*24)
                        
            //Get yesterday steps
            self.pedometer.queryPedometerDataFromDate(fromStartYesterday, toDate: fromStartToday) {
                (pedData: CMPedometerData!, error: NSError!) -> Void in
                let yesterdaySteps = pedData.numberOfSteps
                dispatch_async(dispatch_get_main_queue()) {
                    self.yesterdayStepsLabel.text = NSString(format: "%d", yesterdaySteps)
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
    
    
    func setGoalLabel(steps: Int)
    {
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playGame(sender: AnyObject) {
        if (self.user.getLifes() > 0) {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController

            self.navigationController?.pushViewController(secondViewController, animated:true)
        }
        else
        {
            var alert = UIAlertView(title: "Zero Lifes", message: "You need at least 1 life to play. Meet your daily goal or overpass it to win lifes!", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
    }

}

