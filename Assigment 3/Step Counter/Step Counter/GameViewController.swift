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

    var scene : PrimitivesScene!
    var motionManager : CMMotionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scnView = self.view as! SCNView
        let nScene = PrimitivesScene()
        scene = nScene
        scnView.scene = scene
        scnView.backgroundColor = UIColor.blackColor()
        scnView.autoenablesDefaultLighting = true
                
        setUpPhysics()
        
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
            
            if (self.scene.rootNode.childNodes.count <= 3){
                self.lostLife()
            }
        }
    }

    func lostLife() {
        
    }
    

    
    func physicsWorld(world: SCNPhysicsWorld,
        didBeginContact contact: SCNPhysicsContact) {
            var nodeA = contact.nodeA
            var nodeB = contact.nodeB
            
            if nodeA .isMemberOfClass(Ball) {
                println("Is Ball")
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
