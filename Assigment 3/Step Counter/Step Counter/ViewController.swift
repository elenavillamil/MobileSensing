//
//  ViewController.swift
//  Step Counter
//
//  Created by Elena Villamil on 2/22/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var yesterdayStepsLabel: UILabel!
    @IBOutlet weak var todayStepsLabel: UILabel!
    @IBOutlet weak var stepsToGoalLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

