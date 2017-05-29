//
//  GameScene.swift
//  B-Popper
//
//  Created by Alex Fetisova on 5/29/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var bg1: BGClass?
    private var bg2: BGClass?
    private var bg3: BGClass?
    
    private var mainCamera: SKCameraNode?
    
    override func didMove(to view: SKView)
    {
        initializeGame()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        manageCamera()
    }
    
    private func initializeGame()
    {
        mainCamera = childNode(withName: "MainCamera") as? SKCameraNode
        bg1 = childNode(withName: "BG1") as? BGClass
        bg2 = childNode(withName: "BG2") as? BGClass
        bg3 = childNode(withName: "BG3") as? BGClass
        
    }
    
    private func manageCamera()
    {
        self.mainCamera!.position.y += 5;
    }
    
} // class
