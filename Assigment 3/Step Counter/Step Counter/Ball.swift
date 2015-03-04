//
//  Ball.swift
//  Step Counter
//
//  Created by Tyler Hargett on 2/23/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//
import Foundation
import SceneKit

class Ball : SCNNode {
    override init() {
        super.init()
        var radius: CGFloat = CGFloat(1.2)
        radius = radius - CGFloat(1)
        let sphereGeometry = SCNSphere(radius: radius)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.redColor()
        
               
        addChildNode(sphereNode)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
