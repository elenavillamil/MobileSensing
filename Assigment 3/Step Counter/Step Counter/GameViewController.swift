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

class GameViewController: UIViewController, SCNSceneRendererDelegate {

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
        
    }
    
    func setUpPhysics() {
        // Detect motion
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) { (accelerometerData, error) in
            let acceleration = accelerometerData.acceleration
            
            let accelX = Float(9.8 * acceleration.x)
            let accelY = Float(-9.8 * acceleration.y)
            let accelZ = Float(9.8 * acceleration.z)
            
            self.scene.physicsWorld.gravity = SCNVector3(x: accelX, y: accelY, z: accelZ)
        }
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
