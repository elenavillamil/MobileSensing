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
        var i: NSInteger = userDefaults.integerForKey("lifes")
        if (userDefaults.objectForKey("lifes") == nil)
        {
            userDefaults.setInteger(0, forKey: "lifes")
        }
        if (userDefaults.objectForKey("goal") == nil)
        {
            userDefaults.setInteger(5000, forKey: "goal")
        }
        if (userDefaults.objectForKey("goalLife") == nil)
        {
            userDefaults.setBool(false, forKey: "goalLife")
        }
        if (userDefaults.objectForKey("extraLifeOne") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeOne")
        }
        if (userDefaults.objectForKey("extraLifeTwo") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeTwo")
        }
        if (userDefaults.objectForKey("extraLifeThree") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeThree")
        }
        if (userDefaults.objectForKey("lastDay") == nil)
        {
            userDefaults.setInteger(0, forKey: "lastDay")
        }
    }
    
    func resetWhenNewDay()
    {
        userDefaults.setBool(false, forKey: "goalLife")
        userDefaults.setBool(false, forKey: "extraLifeOne")
        userDefaults.setBool(false, forKey: "extraLifeTwo")
        userDefaults.setBool(false, forKey: "extraLifeThree")
    }
    
    func getLifes() -> Int
    {
        return userDefaults.integerForKey("lifes")
    }
    
    func getGoal() -> Int
    {
        return userDefaults.integerForKey("goal")
    }
    
    func getGoalLife() -> Bool
    {
        return userDefaults.boolForKey("goalLife")
    }
    
    func getExtraLifeOne() -> Bool
    {
        return userDefaults.boolForKey("extraLifeOne")
    }
    
    func getExtraLifeTwo() -> Bool
    {
        return userDefaults.boolForKey("extraLifeTwo")
    }
    
    func getExtraLifeThree() -> Bool
    {
        return userDefaults.boolForKey("extraLifeThree")
    }
    
    func getLastDay() -> Int
    {
        return userDefaults.integerForKey("lastDay")
    }

    func setLifes(lifes: Int)
    {
        userDefaults.setInteger(lifes, forKey: "lifes")
    }
    
    func setGoal(goal: Int)
    {
        userDefaults.setInteger(goal, forKey: "goal")
    }
    
    func setGoalLife(set: Bool)
    {
        userDefaults.setBool(set, forKey: "goalLife")
    }
    
    func setExtraLifeOne(set: Bool)
    {
        userDefaults.setBool(set, forKey: "extraLifeOne")
    }
    
    func setExtraLifeTwo(set: Bool)
    {
        userDefaults.setBool(set, forKey: "extraLifeTwo")
    }
    
    func setExtraLifeThree(set: Bool)
    {
        userDefaults.setBool(set, forKey: "extraLifeThree")
    }
    
    func setLastDay(day: Int)
    {
        userDefaults.setInteger(day, forKey: "lastDay");
    }
}