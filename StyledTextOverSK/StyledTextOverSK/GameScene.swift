//
//  GameScene.swift
//  StyledTextOverSK
//
//  Created by Andrew Dent on 22/7/18.
//  Copyright © 2018 Aussie Designed Software Pty Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // from initial template
        // Get label node from scene and store it for use later
        //self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
      
        if #available(iOS 11.0, *) {
          self.label = SKLabelNode(attributedText: fancyHello())
          // WARNING our label will NOT wrap to fit by default, using these calls possibly introduced in iOS 11
          self.label?.lineBreakMode = .byWordWrapping
          self.label?.numberOfLines = 0  // the KEY to making it wrap, otherwise default is 1 line that goes off edge of screen
        }
        else{
          self.label = SKLabelNode(text:"Hello monostyle world")
        }
        if let label = self.label {
            // because we haven't added it in the GameScene visual editor, need to add manually
            scene?.addChild(label)
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
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

  // method generated by Attributed String Creator, giving you visual editing to generate your choice of code for Swift, ObjC and iOS or MacOS
  // by Mark Bridges http://www.bridgetech.io/
  func fancyHello() -> NSAttributedString
  {
    // Create the attributed string
    let myString = NSMutableAttributedString(string:"Hello SKWorld\nAndy Really likes SpriteKit\nand \n“Attributed String Creator”")
    
    // Declare the fonts
    let myStringFont1 = UIFont(name:"Avenir-Book", size:48.0)!
    let myStringFont2 = UIFont(name:"Didot", size:48.0)!
    let myStringFont3 = UIFont(name:"Didot-Italic", size:48.0)!
    let myStringFont4 = UIFont(name:"MarkerFelt-Thin", size:64.0)!
    
    // Declare the colors
    let myStringColor1 = UIColor(red: 0.447059, green: 0.172549, blue: 0.992157, alpha: 1.000000)
    let myStringColor2 = UIColor(red: 0.207582, green: 1.000000, blue: 0.190665, alpha: 1.000000)
    let myStringColor3 = UIColor(red: 0.989718, green: 0.463134, blue: 0.435260, alpha: 1.000000)
    
    // Declare the paragraph styles
    let myStringParaStyle1 = NSMutableParagraphStyle()
    myStringParaStyle1.alignment = NSTextAlignment.center
    myStringParaStyle1.tabStops = [NSTextTab(textAlignment: NSTextAlignment.left, location: 28.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 56.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 84.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 112.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 140.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 168.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 196.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 224.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 252.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 280.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 308.000000, options: [:]), NSTextTab(textAlignment: NSTextAlignment.left, location: 336.000000, options: [:]), ]
    
    
    // Create the attributes and add them to the string
    myString.addAttribute(NSAttributedStringKey.foregroundColor, value:myStringColor1, range:NSMakeRange(0,13))
    myString.addAttribute(NSAttributedStringKey.paragraphStyle, value:myStringParaStyle1, range:NSMakeRange(0,13))
    myString.addAttribute(NSAttributedStringKey.font, value:myStringFont1, range:NSMakeRange(0,13))
    myString.addAttribute(NSAttributedStringKey.foregroundColor, value:myStringColor2, range:NSMakeRange(13,6))
    myString.addAttribute(NSAttributedStringKey.paragraphStyle, value:myStringParaStyle1, range:NSMakeRange(13,6))
    myString.addAttribute(NSAttributedStringKey.font, value:myStringFont2, range:NSMakeRange(13,6))
    myString.addAttribute(NSAttributedStringKey.foregroundColor, value:myStringColor2, range:NSMakeRange(19,6))
    myString.addAttribute(NSAttributedStringKey.paragraphStyle, value:myStringParaStyle1, range:NSMakeRange(19,6))
    myString.addAttribute(NSAttributedStringKey.font, value:myStringFont3, range:NSMakeRange(19,6))
    myString.addAttribute(NSAttributedStringKey.foregroundColor, value:myStringColor2, range:NSMakeRange(25,22))
    myString.addAttribute(NSAttributedStringKey.paragraphStyle, value:myStringParaStyle1, range:NSMakeRange(25,22))
    myString.addAttribute(NSAttributedStringKey.font, value:myStringFont2, range:NSMakeRange(25,22))
    myString.addAttribute(NSAttributedStringKey.foregroundColor, value:myStringColor3, range:NSMakeRange(47,27))
    myString.addAttribute(NSAttributedStringKey.paragraphStyle, value:myStringParaStyle1, range:NSMakeRange(47,27))
    myString.addAttribute(NSAttributedStringKey.font, value:myStringFont4, range:NSMakeRange(47,27))
    
    return NSAttributedString(attributedString:myString)
  }
  
}
