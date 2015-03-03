//
//  User.swift
//  Step Counter
//
//  Created by Elena Villamil on 2/25/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import Foundation

class User {
    
    class var sharedInstance: User {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: User? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = User()
        }
        return Static.instance!
    }
    
    var yesterdaySteps = 0;
    var todaySteps = 0;
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    init()
    {
        userDefaults.setInteger(0, forKey: "lifes");
        userDefaults.setInteger(5000, forKey: "goal");
    }
    
    func getLifes() -> Int
    {
        return userDefaults.integerForKey("lifes");
    }
    
    func getGoal() -> Int
    {
        return userDefaults.integerForKey("goal");
    }
    
    func setLifes(lifes: Int)
    {
        userDefaults.setInteger(lifes, forKey: "lifes");
    }
    
    func setGoal(goal: Int)
    {
        userDefaults.setInteger(goal, forKey: "goal");
    }
}