//
//  GameScene.swift
//  B-Popper
//
//  Created by Alex Fetisova and Reza Asad on 5/29/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var bg1: BGClass?
    private var bg2: BGClass?
    private var bg3: BGClass?
    private var mainCamera: SKCameraNode?
    private var balloon: BalloonClass?
    
    let UPWARD_SPEED: CGFloat = 5
    
    override func didMove(to view: SKView)
    {
        initializeGame()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        manageBG()
        manageCamera()
        manageBalloon()
    }
    
    private func initializeGame()
    {
        mainCamera = childNode(withName: "MainCamera") as? SKCameraNode
        bg1 = childNode(withName: "BG1") as? BGClass!
        bg2 = childNode(withName: "BG2") as? BGClass!
        bg3 = childNode(withName: "BG3") as? BGClass!
        balloon = childNode(withName: "balloon") as? BalloonClass
        balloon!.wiggleBalloon()
        
    }
    
    private func manageCamera()
    {
        self.mainCamera?.position.y += UPWARD_SPEED
    }
    
    private func manageBalloon()
    {
        self.balloon?.position.y += UPWARD_SPEED
    }
    
    private func manageBG()
    {
        bg1?.moveBG(camera: mainCamera!)
        bg2?.moveBG(camera: mainCamera!)
        bg3?.moveBG(camera: mainCamera!)
    }
    
} // class
