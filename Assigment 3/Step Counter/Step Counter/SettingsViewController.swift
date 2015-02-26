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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func confirmNewGoal(sender: AnyObject) {
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
