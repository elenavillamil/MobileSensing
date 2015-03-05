//
//  WinWall.swift
//  Step Counter
//
//  Created by Tyler Hargett on 3/4/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

import Foundation
import SceneKit

class WinWall: SCNNode {
    override init() {
        super.init()
        let sphereGeometry = SCNBox(width: 0.5, height: 0.5, length: 1.5, chamferRadius: 0)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
        
        
        addChildNode(sphereNode)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
