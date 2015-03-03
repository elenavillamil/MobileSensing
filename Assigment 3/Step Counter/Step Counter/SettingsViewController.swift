//
//  SettingsViewController.swift
//  Step Counter
//
//  Created by Elena Villamil on 2/22/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var setGoalTextField: UITextField!
    
    let user = User.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goalLabel.text = NSString (format: "%d", self.user.getGoal())

        // Do any additional setup after loading the view.
    }

    @IBAction func confirmNewGoal(sender: AnyObject) {
        let newGoal = self.setGoalTextField.text
        if (newGoal.toInt() > 3000)
        {
            self.goalLabel.text = newGoal
            self.user.setGoal(newGoal.toInt()!)
        }
        else
        {
            // Pop up
        }
        // check new goal is all numeric???
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
