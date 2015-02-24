//
//  PrimitivesScene.swift
//  SceneKitTutorial1
//
//  Created by Silviu Pop on 10/23/14.
//  Copyright (c) 2014 We Heart Swift. All rights reserved.
//

import SceneKit

class PrimitivesScene: SCNScene {

    override init() {
        super.init()
        
        setCameraPostion()
        addWalls()
        addFloor()
        testBall()
    
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func testBall() {
        let ball = Ball()
        ball.position = SCNVector3(x: 3.0, y: 0.0, z: 0.0)
        ball.physicsBody = SCNPhysicsBody.dynamicBody()
        self.rootNode.addChildNode(ball)
    }
    
    func setCameraPostion() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        rootNode.addChildNode(cameraNode)
    }
    
    func addFloor()
    {
        let wall = SCNPlane(width: 30.0, height: 30.0)
        wall.firstMaterial?.doubleSided = true
        wall.firstMaterial?.diffuse.contents = UIColor.blueColor()
        
        let wallNode = SCNNode()
        wallNode.geometry = wall
        wallNode.physicsBody = SCNPhysicsBody.staticBody()
        wallNode.position = SCNVector3(x: 0.0, y: 0.0, z:0)
        
        rootNode.addChildNode(wallNode)
    }
    
    func addWalls() {
          
        let wall = SCNBox(width: 1.0, height: 1, length: 3.0, chamferRadius: 0.0)
        wall.firstMaterial?.doubleSided = true
        wall.firstMaterial?.diffuse.contents = UIColor.blueColor()
            
        let wallNode = SCNNode()
        wallNode.geometry = wall
        wallNode.physicsBody = SCNPhysicsBody.staticBody()
        wallNode.position = SCNVector3(x: 0.0, y: 0.0, z:0)
            
        rootNode.addChildNode(wallNode)
            
    }
}
