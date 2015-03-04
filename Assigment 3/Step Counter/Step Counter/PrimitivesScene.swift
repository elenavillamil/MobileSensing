//
//  PrimitivesScene.swift
//  SceneKitTutorial1
//
//  Created by Silviu Pop on 10/23/14.
//  Copyright (c) 2014 We Heart Swift. All rights reserved.
//

import SceneKit

class PrimitivesScene: SCNScene {
    
    var gameBall : Ball!
    var deathFloor : DeathFloor = DeathFloor()
    
    override init() {
        super.init()
        
        setCameraPostion()
//        addWalls()
        addFloor()
        testBall()
        addDeathFloor()

    
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addDeathFloor() {
//        let floor = SCNFloor()
//        floor.firstMaterial?.diffuse.contents = UIColor.greenColor();
//        let floorNode = SCNNode(geometry: floor)
//        floorNode.position.y = -2.5
//        
//        self.rootNode.addChildNode(floorNode)
        
        let wall = SCNPlane(width: 300.0, height: 300.0)
        wall.firstMaterial?.doubleSided = true
        wall.firstMaterial?.diffuse.contents = UIColor.greenColor()
        
        deathFloor.geometry = wall
        deathFloor.physicsBody = SCNPhysicsBody.staticBody()
        deathFloor.position = SCNVector3(x: 0.0, y: 0.0, z:-30)
        
        rootNode.addChildNode(deathFloor)
    }
    
    func testBall() {
        let ball = Ball()
        ball.position = SCNVector3(x: 3.0, y: 0.0, z: 0.0)
        ball.physicsBody = SCNPhysicsBody.dynamicBody()
        
        gameBall = ball
        self.rootNode.addChildNode(gameBall)
    }
    
    func setCameraPostion() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        rootNode.addChildNode(cameraNode)
    }
    
    func addFloor()
    {
        var wallNode = SCNNode()
        
        let workingScene = SCNScene(named: "table_model.dae")
        let nodeArray = workingScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            wallNode.addChildNode(childNode as SCNNode)
        }
        
        wallNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        
        
        //wallNode.pivot = SCNMatrix4MakeRotation(angle: CGFloat(M_PI_2), x: 1, y: 0, z: 0)
        //wallNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: 0)
        
        wallNode.eulerAngles = SCNVector3Make(Float(M_PI_2), 0.0, 0.0)
        wallNode.physicsBody = SCNPhysicsBody.staticBody()
        
        //let wall = SCNPlane(width: 30.0, height: 30.0)
        //wall.firstMaterial?.doubleSided = true
        //wall.firstMaterial?.diffuse.contents = UIColor.blueColor()
        
        //let wallNode = SCNNode()
        //wallNode.geometry = wall
        //wallNode.physicsBody = SCNPhysicsBody.staticBody()
        
        rootNode.addChildNode(wallNode)
    }
    
    func addWalls() {
          
        let wall = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let wallNode = SCNNode()
        wallNode.geometry = wall
        wallNode.physicsBody = SCNPhysicsBody.staticBody()
        wallNode.position = SCNVector3(x: 0.0, y: 0.0, z:-6)
            
        rootNode.addChildNode(wallNode)
            
    }
}
