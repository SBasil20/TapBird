//
//  GameScene.swift
//  TapBird
//
//  Created by Shruti  on 2016-09-17.
//  Copyright (c) 2016 Shruti. All rights reserved.
//

import SpriteKit
import QuartzCore

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    let flapDuration: NSTimeInterval = 0.15
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    var coin = SKSpriteNode()
    var coinPresent = false
    
    var movingObjects = SKSpriteNode()
    
    var gameOver = false
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 0
    }
    
    func makeBackground () {
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let movebg = SKAction.moveByX( -bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let movebgForever = SKAction.repeatActionForever(SKAction.sequence([movebg,replacebg]))
        
        for var i = 0 ; i < 3 ; i++ {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i) , y: CGRectGetMidY(self.frame) )
            bg.size.height = self.frame.height
            bg.runAction(movebgForever)
            self.addChild(bg)
        }
    }
    
    func makeCoin () {
        let coinTexture = SKTexture(imageNamed: "coin.png")
        coin = SKSpriteNode(texture: coinTexture )
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height/1.5)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/3
        
        coin.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + pipeOffset )
        let rotate = SKAction.rotateByAngle(CGFloat(2*M_PI), duration: 1)
        
        //coin.runAction(SKAction.repeatActionForever(rotate))
       
        var action0 = SKAction.scaleXTo(1.0, duration: 0.5)
        var action1 = SKAction.scaleXTo(-1.0, duration: 0.5)
        var action = SKAction.sequence([action0, action1])
        coin.runAction(SKAction.repeatActionForever(action))
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coinTexture.size().height/2)
        coin.physicsBody?.dynamic = false
        coin.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        coin.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        coin.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        coin.name = "coin"
        
        coin.zPosition = 20
        coinPresent = true
        movingObjects.addChild(coin)
    }
    
    override func didMoveToView(view: SKView ) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        makeBackground()
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdtexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture,birdtexture2], timePerFrame: flapDuration)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) )
        
        //mod to prevent bird from rotating
        bird.physicsBody?.allowsRotation = false
        
        // Just for fun code 
        /*
        var bird2 = SKSpriteNode(texture: SKTexture(imageNamed: "flappy1.png"))
        var zoomIn = SKAction.scaleBy(1.2, duration: 1)
        var zoomOut = SKAction.scaleBy(1/1.2, duration: 1)
        let zooomSequence = SKAction.sequence([zoomIn,zoomOut])
        bird2.runAction(SKAction.repeatActionForever(zooomSequence))
        
        bird2.position = CGPoint(x: bird.frame.origin.x - 20, y: bird.frame.origin.y - 20)
        self.addChild(bird2)
        */
        
        
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 15
        self.addChild(scoreLabel)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody?.dynamic = true
        
        bird.runAction(makeBirdFlap)
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(bird)
        
        var ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width , 1) )
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "makePipes", userInfo: nil, repeats: true)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "makeCoinsRandom", userInfo: nil, repeats: true)
        
        //makeCoin()
    }
    
    func makeCoinsRandom () {
        if coinPresent == false {
            makeCoin()
            coinPresent = true
        }
        else
        {
            coin.removeFromParent()
            makeCoin()
            coinPresent = true
        }
    }
    
    func makePipes () {
        let gapHeight  = bird.size.height * 5
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width*2, y: 0, duration: NSTimeInterval(self.frame.width/100) )
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width , y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset )
        pipe1.runAction(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width , y: CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2Texture.size())
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        pipe1.zPosition = 10
        pipe2.zPosition = 11
        
        movingObjects.addChild(pipe2)
        movingObjects.addChild(pipe1)
        
        var gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
       if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
        //print("score")
        scoreLabel.text = "\(score)"
        
        if contact.bodyA.node?.name == "coin" || contact.bodyB.node?.name == "coin" {
            print("coin touched")
            coin.removeFromParent()
        }
        
        }
       else {
        if gameOver == false {
        //print("We have contact")
        gameOver = true
        
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "Game Over! Tap to play again"
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        gameOverLabel.zPosition = 15
        labelContainer.addChild(gameOverLabel)
        
        self.speed = 0
        }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if (gameOver == false) {
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50)) }
        else {
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.angularVelocity = 0.0
            
            coin.removeFromParent()
            self.addChild(coin)
            
            movingObjects.removeAllChildren()
            makeBackground()
            
            self.speed  = 1
            
            gameOver = false
            labelContainer.removeAllChildren()
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
