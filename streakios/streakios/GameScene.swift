//
//  GameScene.swift
//  streakios
//
//  Created by ad on 22/1/18.
//  Copyright © 2018 Aussie Designed Software Pty Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var sparkNode: SKSpriteNode?
    private var sparkTrail: SKxMotionStreak?
    private let scaledOnTouchBy = CGFloat(4.0)
    
    override func didMove(to view: SKView) {
      sparkNode = self.childNode(withName: "//SparkNode") as? SKSpriteNode
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
      sparkNode?.position = pos
      sparkNode?.run(SKAction.scale(by: scaledOnTouchBy, duration:0.1))
      sparkTrail = SKxMotionStreak()
      addChild(sparkTrail!)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
      sparkNode!.position = pos
      sparkTrail!.addPosition(position: pos)
      sparkTrail!.updateStreak()
    }
    
    func touchUp(atPoint pos : CGPoint) {
      sparkNode!.position = pos
      sparkTrail!.addPosition(position: pos)
      sparkTrail!.updateStreak()
      sparkNode!.run(SKAction.scale(by: 1.0/scaledOnTouchBy, duration:0.5))
      removeChildren(in: [sparkTrail!])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
