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
        if (userDefaults.objectForKey("lifes") == nil)
        {
            userDefaults.setInteger(0, forKey: "lifes")
        }
        if (userDefaults.objectForKey("goal") == nil)
        {
            userDefaults.setInteger(5000, forKey: "goal")
        }
        if (userDefaults.objectForKey("extreLifeOne") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeOne")
        }
        if (userDefaults.objectForKey("extreLifeTwo") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeTwo")
        }
        if (userDefaults.objectForKey("extreLifeThree") == nil)
        {
            userDefaults.setBool(false, forKey: "extraLifeThree")
        }
    }
    
    func resetAtTheEndOfDay()
    {
        userDefaults.setBool(false, forKey: "extraLifeOne")
        userDefaults.setBool(false, forKey: "extraLifeTwo")
        userDefaults.setBool(false, forKey: "extraLifeThree")
    }
    
    func getLifes() -> Int
    {
        return userDefaults.integerForKey("lifes");
    }
    
    func getGoal() -> Int
    {
        return userDefaults.integerForKey("goal");
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