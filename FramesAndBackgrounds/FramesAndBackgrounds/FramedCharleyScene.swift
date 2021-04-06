//
//  GameScene.swift
//  FramesAndBackgrounds
//
//  Created by AndyDent on 1/2/21.
//

import SpriteKit
import GameplayKit

class FramedCharleyScene: SKScene {    
   
    override func didMove(to view: SKView) {
/*        let topLabel = self.childNode(withName: "//topLabel") as? SKLabelNode
        topLabel?.position.y = view.frame.height - 4
        let bottomLabel = self.childNode(withName: "//bottomLabel") as? SKLabelNode
        bottomLabel?.position.y = 4
        let background = self.childNode(withName: "//fullpageBackground") as? SKSpriteNode
        //todo set it to full size background.
        //background?.position.y = view.frame.height*/
        
        // create a "background" node with image stretched filling the entire view
        let charley = SKSpriteNode(imageNamed: "CharleyLookingUp")
        charley.size = view.frame.size
        charley.position = CGPoint(x:0.0, y:0.0)
        charley.anchorPoint = CGPoint(x:0.0, y:0.0)
        addChild(charley)

        // use a shader to cut out only part of the stretched image - comment out this line to see whole pic
        let cutOut = SKSpriteNode(color: .green, size:view.frame.size)
        cutOut.shader = SKShader(fileNamed: "OvalCutout.fsh")
        cutOut.position = CGPoint(x:0.0, y:0.0)
        cutOut.anchorPoint = CGPoint(x:0.0, y:0.0)
        charley.addChild(cutOut)
}
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
