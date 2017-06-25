//
//  BalloonClass.swift
//  Up
//
//  Created by Reza Asad on 6/24/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//

import SpriteKit

class BalloonClass: SKSpriteNode
{
    private var balloonAnimation  = [SKTexture]()
    private var animateBalloonWiggle = SKAction()
    
    func wiggleBalloon()
    {
        for name in ["balloon_right", "balloon_left"] {
            balloonAnimation.append(SKTexture(imageNamed: name))
        }
        
        animateBalloonWiggle = SKAction.animate(
            with: balloonAnimation,
            timePerFrame: 0.3,
            resize: true,
            restore: false
        )
        
        self.run(SKAction.repeatForever(animateBalloonWiggle))
    }
} 
