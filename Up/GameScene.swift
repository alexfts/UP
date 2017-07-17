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
    
    let UPWARD_SPEED: CGFloat = 2
    let TREE_Z_POSITION: CGFloat = 5
    let MIN_GAP_SCALAR: CGFloat = 1.5
    let MAX_GAP_SCALAR: CGFloat = 2.5
    let SAFETY_NET_X = CGFloat(40.0)
    let BRANCH_SCALE = CGFloat(0.3)
    let BRANCH_WIDTH_SCALE = CGFloat(1.2)
    let MAX_NUM_BRANCHES = 3
    let FIXED_BRANCH_GAP: CGFloat = 900
    
    private var bg1: BGClass?
    private var bg2: BGClass?
    private var bg3: BGClass?
    private var mainCamera: SKCameraNode?
    private var balloon: BalloonClass?
    private var leftBranch: SKSpriteNode?
    private var rightBranch: SKSpriteNode?
    private var extraHeight: CGFloat = 0
    private var prevActions = [0, 0, 0]
    
    private var initialTouchTime: TimeInterval?
    private var initialTouchPosition: CGPoint?
    private var timer: Timer = Timer()
    
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
        
        Timer.scheduledTimer(timeInterval: TimeInterval(7), target: self, selector: #selector(self.removeItems), userInfo: nil, repeats: true)
        
        // Add and remove branches
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.run(decideOnMakingBranch)
                ])
        ))

    }
    
    private func manageCamera()
    {
        self.mainCamera?.position.y += UPWARD_SPEED
    }
    
    private func manageBalloon()
    {
        // check if balloon went outside of the bounds
        if (isBalloonTouchingScreenEdge()) { gameOver() }
        self.balloon?.position.y += UPWARD_SPEED
    }
    
    private func manageBG()
    {
        bg1?.moveBG(camera: mainCamera!)
        bg2?.moveBG(camera: mainCamera!)
        bg3?.moveBG(camera: mainCamera!)
    }
    
    private func decideOnMakingBranch()
    {
        if prevActions.reduce(0,+) == 0 {
            createBranch()
            prevActions.insert(1, at: 0)
        } else {
            let coinValue = Int(arc4random_uniform(2))
            print(coinValue)
            if coinValue == 1 {
                createBranch()
            }
            prevActions.insert(coinValue, at: 0)
        }
        prevActions.removeLast()
    }
    private func chooseObstacleType(height: CGFloat)
    {
        let balloonWidth = balloon!.size.width
        let sceneWidth = self.size.width
        let remainingWidth = (sceneWidth - balloonWidth)
        
        // Define the left and right branches
        leftBranch = SKSpriteNode(imageNamed: "left_branch")
        rightBranch = SKSpriteNode(imageNamed: "right_branch")
        leftBranch?.setScale(BRANCH_SCALE)
        rightBranch?.setScale(BRANCH_SCALE)
        leftBranch?.size.width = (leftBranch?.size.width)! * BRANCH_WIDTH_SCALE
        rightBranch?.size.width = (rightBranch?.size.width)! * BRANCH_WIDTH_SCALE
        
        // Choose the difficuty level and Gaps's position
        var gapX0 = random(min:CGFloat(-sceneWidth / 2.0), max: CGFloat(-sceneWidth / 2.0) + remainingWidth)
        let betweenBranchGap = random(min: CGFloat(balloonWidth * MIN_GAP_SCALAR), max: CGFloat(balloonWidth * MAX_GAP_SCALAR))
        var gapX1 = gapX0 + betweenBranchGap
        
        // Make the cases on the edge of the screen easier
        if gapX0 - SAFETY_NET_X < -sceneWidth / 2.0{
            gapX0 = gapX0 + SAFETY_NET_X
            gapX1 = gapX1 + SAFETY_NET_X
        }
        if gapX1 + SAFETY_NET_X > sceneWidth / 2.0{
            gapX1 = gapX1 - SAFETY_NET_X
            gapX0 = gapX0 - SAFETY_NET_X
        }


        // Position the left and right branches
        let branchWidth = leftBranch!.size.width
        let leftBranchXPos = gapX0 - (branchWidth / 2.0)
        let rightBranchXPos = gapX1 + (branchWidth / 2.0)
        leftBranch?.position = CGPoint(x: leftBranchXPos, y: height)
        rightBranch?.position = CGPoint(x: rightBranchXPos, y: height)
        leftBranch?.zPosition = TREE_Z_POSITION
        rightBranch?.zPosition = TREE_Z_POSITION
        
    }
    
    private func createBranch()
    {
        let nextBranchYPos = (self.mainCamera?.position.y)! + FIXED_BRANCH_GAP
        chooseObstacleType(height: nextBranchYPos)
        addBranch()
    }
    private func addBranch()
    {
        initializePhysicsWorld(node: leftBranch!)
        initializePhysicsWorld(node: rightBranch!)
        
        // Set bitmask and collision mask for banch
        setBitMask(node: leftBranch!, categoryBitMask: PhysicsCategory.branch, contactTestBitMask: PhysicsCategory.balloon)
        setBitMask(node: rightBranch!, categoryBitMask: PhysicsCategory.branch, contactTestBitMask: PhysicsCategory.balloon)
        addChild(leftBranch!)
        addChild(rightBranch!)
        
        // Remove the branch after 20 seconds
//        let actionMoveDone = SKAction.removeFromParent()
//        leftBranch?.run(SKAction.sequence([SKAction.wait(forDuration: 15), actionMoveDone]))
//        rightBranch?.run(SKAction.sequence([SKAction.wait(forDuration: 15), actionMoveDone]))

    }
    
    func removeItems() {
        for child in children {
            if child.name == "left_branch" || child.name == "right_branch" {
                if child.position.y + self.size.height / 2.0 < self.mainCamera!.position.y {
                    child.removeFromParent();
                }
            }
        }
    }
    
    private func baloonDidCollideWithObstacle()
    {
        balloon?.removeFromParent()
//        gameOver()
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
                baloonDidCollideWithObstacle()
            }
    }
    
    private func gameOver()
    {
        let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    private func isBalloonTouchingScreenEdge() -> Bool
    {
        let x = balloon!.position.x
        let y = balloon!.position.y
        let halfwidth = balloon!.size.width / 2.0
        let halfheight = balloon!.size.height / 2.0
        
        let topy = mainCamera!.position.y + self.size.height / 2.0
        let bottomy = mainCamera!.position.y - self.size.height / 2.0
        let leftx = -self.size.width / 2
        let rightx = self.size.width / 2
        
        if (x + halfwidth >= rightx) { return true } // right
        if (x - halfwidth <= leftx) { return true } // left
        if (y + halfheight >= topy) { return true } // top
        if (y - halfheight <= bottomy) { return true } // bottom
        
        return false
    }

} // class
