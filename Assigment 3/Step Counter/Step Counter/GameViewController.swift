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

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

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
        scene.removeBall()
        
        var currentLives = user.getLifes() - 1
        
        if (currentLives >= 0)
        {
            self.user.setLifes(currentLives)
            dispatch_async(dispatch_get_main_queue()) {
                self.livesLabel.text = NSString(format: "Lives: %d", currentLives)
            }
        }
        
        if (currentLives > 0) {
            var alert = UIAlertController(title: "You died!", message: "The Ball fell off the map...", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                
            }
            alert.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Play again", style: .Default) { (action) in
                // ...
                self.newBall()
            }
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "You died!", message: "The Ball fell off the map...", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                
            }
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
        
    }
    
    func newBall() {
        scene.addBall()
    }
    
    func winner() {
        var alert = UIAlertController(title: "You won!", message: "You obviously played this way to much. You show stop...", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Play again", style: .Default) { (action) in
            // ...
            self.newBall()
        }
        alert.addAction(OKAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func physicsWorld(world: SCNPhysicsWorld,
        didBeginContact contact: SCNPhysicsContact) {
            var nodeA = contact.nodeA
            var nodeB = contact.nodeB
            
            if nodeA.isKindOfClass(Ball) && nodeB.isKindOfClass(DeathFloor) {
                println("You Died")
                lostLife()
            } else if nodeA.isKindOfClass(Ball) && nodeB.isKindOfClass(WinWall) {
                winner()
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
