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
        userDefaults.setInteger(0, forKey: "lifes")
        userDefaults.setInteger(5000, forKey: "goal")
        userDefaults.setInteger(0, forKey: "today")
        userDefaults.setInteger(0, forKey: "yesterday")
        userDefaults.setBool(false, forKey: "extraLifeOne")
        userDefaults.setBool(false, forKey: "extraLifeTwo")
        userDefaults.setBool(false, forKey: "extraLifeThree")
    }
    
    func resetAtTheEndOfDay(endSteps: Int)
    {
        userDefaults.setBool(false, forKey: "extraLifeOne")
        userDefaults.setBool(false, forKey: "extraLifeTwo")
        userDefaults.setBool(false, forKey: "extraLifeThree")
        userDefaults.setInteger(endSteps, forKey: "yesterday")
    }
    
    func getLifes() -> Int
    {
        return userDefaults.integerForKey("lifes");
    }
    
    func getGoal() -> Int
    {
        return userDefaults.integerForKey("goal");
    }
    
    func getTodaySteps() -> Int
    {
        return userDefaults.integerForKey("today");
    }
    
    func getYesterdaySteps() -> Int
    {
        return userDefaults.integerForKey("yesterday");
    }
    
    func getExtraLifeOne() -> Bool
    {
        return userDefaults.boolForKey("extraLifeOne");
    }
    
    func getExtraLifeTwo() -> Bool
    {
        return userDefaults.boolForKey("extraLifeTwo");
    }
    
    func getExtraLifeThree() -> Bool
    {
        return userDefaults.boolForKey("extraLifeThree");
    }
    
    func setLifes(lifes: Int)
    {
        userDefaults.setInteger(lifes, forKey: "lifes");
    }
    
    func setGoal(goal: Int)
    {
        userDefaults.setInteger(goal, forKey: "goal");
    }
    
    func setTodaySteps(today: Int)
    {
        userDefaults.setInteger(today, forKey: "today");
    }
    
    func setYesterdaySteps(yesterday: Int)
    {
        userDefaults.setInteger(yesterday, forKey: "yesterday");
    }
    
    func setExtraLifeOne(set: Bool)
    {
        userDefaults.setBool(set, forKey: "ExtraLifeOne");
    }
    
    func setExtraLifeTwo(set: Bool)
    {
        userDefaults.setBool(set, forKey: "extraLifeTwo");
    }
    
    func setExtraLifeThree(set: Bool)
    {
        userDefaults.setBool(set, forKey: "extraLifeThree");
    }
}