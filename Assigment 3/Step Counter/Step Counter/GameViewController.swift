//
//  GameViewController.swift
//  Step Counter
//
//  Created by Tyler Hargett on 2/23/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import UIKit
import SceneKit
import OpenGLES
import CoreMotion
import QuartzCore

class GameViewController: UIViewController, UIAlertViewDelegate, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    @IBOutlet weak var livesLabel: UILabel!
    var scene : PrimitivesScene!
    var motionManager : CMMotionManager!
    var user = User.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scnView = self.view as SCNView
        let nScene = PrimitivesScene()
        scene = nScene
        scnView.scene = scene
        scnView.backgroundColor = UIColor.blackColor()
        scnView.autoenablesDefaultLighting = true
                
        setUpPhysics()
        var lifesString: NSString = "\(user.getLifes())"
        var frontString: NSString = "Lives: "
        livesLabel.text = frontString.stringByAppendingString(lifesString)
        scene.physicsWorld.contactDelegate = self
    
    }
    

    
    func setUpPhysics() {
        // Detect motion
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) { (accelerometerData, error) in
            let acceleration = accelerometerData.acceleration
            
            let accelX = Float(9.8 * acceleration.x)
            let accelY = Float(9.8 * acceleration.y)
            let accelZ = Float(50 * acceleration.z)
            
            self.scene.physicsWorld.gravity = SCNVector3(x: accelX, y: accelY, z: accelZ)
            
        }
    }

    func lostLife() {
        var currentLives = user.getLifes() - 1
        user.setLifes(currentLives)
        if (currentLives > 0) {
            var alert = UIAlertView(title: "You Died!", message: "The Ball fell off the map...", delegate: self, cancelButtonTitle: "Quit", otherButtonTitles: "Try Again")
            alert.show()
        } else {
            var alert = UIAlertView(title: "You Died!", message: "The Ball fell off the map... And have no lives left. Walk more for extra lives", delegate: self, cancelButtonTitle: "Okay")
        }
        
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //if alertView.title
    }
    

    
    func physicsWorld(world: SCNPhysicsWorld,
        didBeginContact contact: SCNPhysicsContact) {
            var nodeA = contact.nodeA
            var nodeB = contact.nodeB
            
            if nodeA.isKindOfClass(Ball) && nodeB.isKindOfClass(DeathFloor) {
                println("You Died")
                lostLife()
            }
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
