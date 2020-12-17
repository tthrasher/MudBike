//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//  Further worked on by Terry Thrasher.
//  Music by Kevin MacLeod: https://incompetech.com/
//
//  Note: I tried changing the Display Name for the project, then a bunch of sprites stopped loading. The player sprite and weapon sprites still happen, but none of the enemy and bonus sprites do.

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player-motorbike.png")
    var touchingPlayer = false
    
    let enemyNames = ["wall", "barrel", "mine"]
    
    var gameTimer: Timer?
    
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let shotsLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var shots = 0 {
        didSet {
            shotsLabel.text = "Shots: \(shots)"
        }
    }
    var shotsCount = 0
    
    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "road.jpg")
        background.zPosition = -1
        addChild(background)
        
        if let particles = SKEmitterNode(fileNamed: "Mud") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        
        addChild(music)
        
        scoreLabel.zPosition = 2
        scoreLabel.position = CGPoint(x: 200, y: 300)
        addChild(scoreLabel)
        score = 0
        
        shotsLabel.zPosition = 2
        shotsLabel.position = CGPoint(x: -200, y: 300)
        addChild(shotsLabel)
        shots = 0
        
        player.position.x = -400
        player.zPosition = 1
        addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createItems), userInfo: nil, repeats: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        player.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
        // Challenge 3 asks me to let tapping the screen fire a weapon at walls
        // I've chosen to implement this whenever the player lifts their touch
        fireWeapon()
    }

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
            if node.position.x > 700 {
                node.removeFromParent()
            }
        }
        
        if player.position.x < -400 {
            player.position.x = -400
        } else if player.position.x > 400 {
            player.position.x = 400
        }
        
        if player.position.y < -300 {
            player.position.y = -300
        } else if player.position.y > 300 {
            player.position.y = 300
        }
    }
    
    /*
    func createEnemy() {
        createBonus()
        
        // Challenge 1 asks me to make multiple enemies, randomly chosen
        let enemyNumber = Int.random(in: 0...2)
        let sprite = SKSpriteNode(imageNamed: "\(enemyNames[enemyNumber])")
        // let sprite = SKSpriteNode(imageNamed: "wall")
        sprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
        sprite.name = "enemy"
        sprite.zPosition = 1
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
    }
    */
    
    /*
    func createBonus() {
        let sprite = SKSpriteNode(imageNamed: "coin")
        sprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
        sprite.name = "bonus"
        sprite.zPosition = 1
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.collisionBitMask = 0
    }
    */
    
    // Challenge 2 asks me to refactor createEnemy() and createBonus() into a single method
    @objc func createItems() {
        shotsCount += 1
        if shotsCount % 5 == 0 {
            shots += 1
        }
        
        let enemyNumber = Int.random(in: 0...2)
        let enemySprite = SKSpriteNode(imageNamed: "\(enemyNames[enemyNumber])")
        let bonusSprite = SKSpriteNode(imageNamed: "coin")
        let sprites = [enemySprite, bonusSprite]
        
        enemySprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
        enemySprite.name = "enemy"
        enemySprite.zPosition = 1
        addChild(enemySprite)
        
        if enemySprite.position.y < 0 {
            bonusSprite.position = CGPoint(x: 1200, y: Int.random(in: 0...350))
        } else {
            bonusSprite.position = CGPoint(x: 1200, y: Int.random(in: -350...0))
        }
        bonusSprite.name = "bonus"
        bonusSprite.zPosition = 1
        addChild(bonusSprite)
        
        for sprite in sprites {
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.contactTestBitMask = 1
            sprite.physicsBody?.categoryBitMask = 0
            if sprite.name == "bonus" {
                sprite.physicsBody?.collisionBitMask = 0
            }
        }
    }
    
    func fireWeapon() {
        if shotsCount >= 5 {
            shotsCount -= 5
            shots -= 1
            
            let sprite = SKSpriteNode(imageNamed: "star")
            sprite.position.x = player.position.x + 80
            sprite.position.y = player.position.y
            sprite.name = "weapon"
            sprite.zPosition = 1
            addChild(sprite)
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.velocity = CGVector(dx: 600, dy: 0)
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.contactTestBitMask = 0
            sprite.physicsBody?.categoryBitMask = 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            if nodeB.name == "enemy" || nodeB.name == "bonus" {
                playerHit(nodeB)
            }
        } else if nodeB == player {
            if nodeA.name == "enemy" || nodeA.name == "bonus" {
                playerHit(nodeA)
            }
        }
        
        if nodeA.name == "weapon" {
            if nodeB.name == "enemy" {
                shotHit(nodeA, nodeB)
            }
        } else if nodeB.name == "weapon" {
            if nodeA.name == "enemy" {
                shotHit(nodeB, nodeA)
            }
        }
    }
    
    // Challenge 3 asks me to allow the player to fire weapons at the obstacles
    // nodeA is the weapon, nodeB is whatever it hit
    func shotHit(_ nodeA: SKNode, _ nodeB: SKNode) {
        if let particles = SKEmitterNode(fileNamed: "Explosion.sks") {
            particles.position = nodeA.position
            particles.zPosition = 3
            addChild(particles)
        }
        nodeA.removeFromParent()
        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)
    }
    
    // If the player was involved in the collision, call this, passing it the non-player collided node
    func playerHit(_ node: SKNode) {
        if node.name == "bonus" {
            score += 1
            node.removeFromParent()
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            
            return
        }
        if let particles = SKEmitterNode(fileNamed: "Explosion.sks") {
            particles.position = player.position
            particles.zPosition = 3
            addChild(particles)
        }
        player.removeFromParent()
        music.removeFromParent()
        let gameOver = SKSpriteNode(imageNamed: "gameOver-3")
        gameOver.zPosition = 10
        addChild(gameOver)
        shots = 0
        shotsCount = 0
        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)
        
        // Wait for two seconds, then take these actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Create a new scene
            if let scene = GameScene(fileNamed: "GameScene") {
                // Stretch it to fill the screen, then show it
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}

