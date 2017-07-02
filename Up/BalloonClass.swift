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

    let WIND_FORCE_UNIT: CGFloat = 150
    //let MOVE_DURATION: Double = 0.001

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
    
    func initializePhysicsWorld()
    {
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        if let physics = self.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = true
            physics.isDynamic = true
            physics.linearDamping = 1.5
            physics.angularDamping = 1.5
        }
    }
    func moveBalloon(touchLocation: CGPoint, touchDuration: TimeInterval)
    {
        let force = (self.position - touchLocation).normalize() *
            WIND_FORCE_UNIT * CGFloat(touchDuration)
        //let windForce = direction * WIND_FORCE_UNIT * CGFloat(touchDuration)
        //let newDestination = self.position + windForce
        //let actionMove = SKAction.move(to: newDestination, duration: MOVE_DURATION)
        
        //self.run(actionMove)
        self.physicsBody!.applyImpulse(CGVector(dx: force.x, dy: force.y))
    }
}
