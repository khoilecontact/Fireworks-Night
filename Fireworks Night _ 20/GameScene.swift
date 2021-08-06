//
//  GameScene.swift
//  Fireworks Night _ 20
//
//  Created by KhoiLe on 22/07/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
        
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 1
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                //this use when the firework is higher than the screen and exploses
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard let SKView = view as? SKView else {
            return
        }
        
        guard let gameScene = SKView.scene as? GameScene else {
            return
        }
        
        gameScene.explodeFireworks()
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        //act as a firework container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        //represent the firework movement
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //tell the container to follow the path
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        //create the particles behind the rocket to make it looks like firework
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(firework)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            //fire fire, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // fire five, in a fan
           createFirework(xMovement: 0, x: 512, y: bottomEdge)
           createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
           createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
           createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
           createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

       case 2:
           // fire five, from the left to the right
           createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
           createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
           createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
           createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
           createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

       case 3:
           // fire five, from the right to the left
           createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
           createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
           createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
           createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
           createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let nodeAtPoint = nodes(at: position)
        
        for case let node as SKSpriteNode in nodeAtPoint {
            guard node.name == "firework" else {
                continue
            }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else {
                    continue
                }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    func explode(firework: SKNode) {
        if let explode = SKEmitterNode(fileNamed: "explode") {
            explode.position = firework.position
            addChild(explode)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks(){
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else {
                continue
            }
            
            if firework.name == "selected" {
                explode(firework: firework)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 100
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
}
