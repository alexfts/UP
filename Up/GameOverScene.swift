//
//  GameOverScene.swift
//  Up
//
//  Created by Alex Fetisova on 7/9/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//


import Foundation
import SpriteKit

class GameOverScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let message = "Pop!💥 Try again."
        
        let label = SKLabelNode(fontNamed: "AppleColorEmoji")
        label.text = message
        label.fontSize = 20
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            run(SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.run() {
                    let doorsClosed = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
                    self.view?.presentScene(scene, transition: doorsClosed)
                }
            ]))
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
