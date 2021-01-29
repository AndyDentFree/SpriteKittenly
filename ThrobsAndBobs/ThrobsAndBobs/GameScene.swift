//
//  GameScene.swift
//  ThrobsAndBobs
//
//  Created by AndyDent on 28/1/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var heartShader : SKShader?
    private var heartShaderNode : SKNode?

    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    private func createHeartShader(width: CGFloat) {
        let ret = SKSpriteNode(color: .yellow, size: CGSize(width: width, height: width))  // use different color from heart so know when debugging that shader didn't draw anything
        if heartShader == nil {
            heartShader = SKShader(fromFile: "ThrobbingHeart2D")  // only one instance needed, which is optimal if many shaders active
        }
        ret.shader = heartShader
        heartShaderNode = ret
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        let hsnWidth = (self.size.width + self.size.height) * 0.1
        if heartShaderNode == nil || !heartShaderNode!.position.close(to:pos, radius: hsnWidth+2.0) {
            // create new one first time or if tap far enough away, just debounces a create and drag
            createHeartShader(width: hsnWidth)
            self.addChild(heartShaderNode!)
        }
        heartShaderNode!.position = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        heartShaderNode?.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // later maybe remove heartShaderNode if you wanted it to vanish after dragging
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
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
