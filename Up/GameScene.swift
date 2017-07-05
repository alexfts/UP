//
//  GameScene.swift
//  B-Popper
//
//  Created by Alex Fetisova and Reza Asad on 5/29/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//

import SpriteKit
import GameplayKit


func + (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


extension CGPoint
{
    func length() -> CGFloat
    {
        return sqrt(x*x+y*y)
    }
    
    func normalize() -> CGPoint
    {
        return self / length()
    }
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let branch   : UInt32 = 0b1
    static let balloon: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var bg1: BGClass?
    private var bg2: BGClass?
    private var bg3: BGClass?
    private var mainCamera: SKCameraNode?
    private var balloon: BalloonClass?
    
    private var initialTouchTime: TimeInterval?
    private var initialTouchPosition: CGPoint?
    private var timer: Timer = Timer()
    
    let UPWARD_SPEED: CGFloat = 4
    let TREE_SCALE: CGFloat = 0.3
    let TREE_Z_POSITION: CGFloat = 5
    
    override func didMove(to view: SKView)
    {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        initializeGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        initialTouchTime = touch.timestamp
        initialTouchPosition = touch.location(in: self)
        balloon!.calculateDirection(touchLocation: initialTouchPosition!)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.moveBalloon(timer:)), userInfo: nil, repeats: true)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        timer.invalidate()
        
    }
    
    @objc private func moveBalloon(timer: Timer)
    {
        let currentTime = Date().timeIntervalSinceReferenceDate
        let touchDuration = (currentTime - initialTouchTime!)
        balloon!.applyForce(touchDuration: touchDuration)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        manageBG()
        manageCamera()
        manageBalloon()
    }
    
    func initializePhysicsWorld(node: SKSpriteNode)
    {
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        if let physics = node.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = true
            physics.isDynamic = true
            physics.linearDamping = 1.5
            physics.angularDamping = 1.5
        }
    }

    func setBitMask(node: SKSpriteNode, categoryBitMask: UInt32, contactTestBitMask: UInt32)
    {
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = contactTestBitMask
        node.physicsBody?.collisionBitMask = PhysicsCategory.None
        node.physicsBody?.usesPreciseCollisionDetection = true
    }

    private func initializeGame()
    {
        mainCamera = childNode(withName: "MainCamera") as? SKCameraNode
        bg1 = childNode(withName: "BG1") as? BGClass!
        bg2 = childNode(withName: "BG2") as? BGClass!
        bg3 = childNode(withName: "BG3") as? BGClass!
        balloon = childNode(withName: "balloon") as? BalloonClass
        initializePhysicsWorld(node: balloon!)
        setBitMask(node: balloon!, categoryBitMask: PhysicsCategory.balloon, contactTestBitMask: PhysicsCategory.branch)
        balloon!.wiggleBalloon()
        
        // Add and remove branches
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addBranch),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
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
    
    private func addBranch()
    {
        // Choose if the branch is created or not using a dice
        let makeBranchDice = random(min: CGFloat(1.0), max: CGFloat(6.0))
        if makeBranchDice < 4 {
            return
        }
        let fixedBranchPosition = ((self.mainCamera?.position.y)! + self.size.height)
        let leftRightCoin = random(min: CGFloat(1.0), max: CGFloat(2.0))
        var branch = SKSpriteNode(imageNamed: "tree_branch_left")
        branch.position = CGPoint(x: -branch.size.width/5, y: fixedBranchPosition)
        
        // Choose if you're going to make a left or right branch
        if leftRightCoin < 1.5 {
            branch = SKSpriteNode(imageNamed: "tree_branch_right")
            branch.position = CGPoint(x: size.width-branch.size.width/3, y: fixedBranchPosition)
        }
        initializePhysicsWorld(node: branch)
        branch.zPosition = TREE_Z_POSITION
        branch.setScale(TREE_SCALE)
        
        // Set bitmask and collision mask for banch
        setBitMask(node: branch, categoryBitMask: PhysicsCategory.branch, contactTestBitMask: PhysicsCategory.balloon)
        addChild(branch)
        
        // Remove the branch after 20 seconds
        let actionMoveDone = SKAction.removeFromParent()
        branch.run(SKAction.sequence([SKAction.wait(forDuration: 20), actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster()
    {
        balloon?.removeFromParent()
//        monstersDestroyed += 1
//        if (monstersDestroyed > 30) {
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: true)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
        
    }

    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.branch != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.balloon != 0)) {
                projectileDidCollideWithMonster()
            }
    }

} // class
