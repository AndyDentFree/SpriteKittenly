//
//  GameScene.swift
//  StyledTextOverSK
//
//  Created by Andrew Dent on 22/7/18.
//  Copyright © 2018 Aussie Designed Software Pty Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit
import WebKit

extension SKScene {
    func makeTransparent() {
        backgroundColor = backgroundColor.withAlphaComponent(0.0)
        self.view?.allowsTransparency = true
    }
    
    func makeOpaque() {
        backgroundColor = backgroundColor.withAlphaComponent(1.0)
        self.view?.allowsTransparency = false
    }
}

enum TextDisplay {
    case multiSprite([SKLabelNode?])
    case sprite(SKLabelNode?)
    case uilabel(UILabel?)
    case web(WKWebView?)
    case webUnder(WKWebView?)
    case webImage(WebviewImageCapturer?)  // renders web view into a node
    case nothing
    
    func removeCurrent(from scene:SKScene?) {
        switch self {
            case .multiSprite(let sprites): sprites.forEach{$0?.removeFromParent()}
            case .sprite(let s): s?.removeFromParent()
            case .uilabel(let l): l?.removeFromSuperview()
            case .web(let wv): wv?.removeFromSuperview()
            case .webUnder(let wv): wv?.removeFromSuperview()
            case .webImage(let wic): wic?.removeFromParent()
            case .nothing: return  // nothing to remove
        }
    }
    
    // cycles around the enum values, manufacturing the next view
    func addNext(on scene:SKScene?) -> TextDisplay {
        removeCurrent(from:scene)
        switch self {
            case .multiSprite: return .sprite(makeLabelNode(on:scene))
            case .sprite: return .uilabel(makeUILabelOverlay(on:scene))
            case .uilabel: return .web(makeWebOverlay(on:scene))
            case .web: return .webUnder(makeWebUnderlay(on:scene))
            case .webUnder:
                scene?.makeOpaque()
                return .webImage(makeWebImage(on:scene))
            case .webImage, .nothing: return .multiSprite(makeTopBottomLabelNodes(on:scene))
        }
    }

    /// make the overlaid string as an SKLabelNode and set self.label
    func makeLabelNode(on scene:SKScene?, fadeIn:Bool=false) -> SKLabelNode?
    {
        var label: SKLabelNode? = nil
        if #available(iOS 11.0, *) {
            label = SKLabelNode(attributedText: fancyHello())
            // WARNING our label will NOT wrap to fit by default, make it wrap using these calls possibly introduced in iOS 11
            label?.lineBreakMode = .byWordWrapping
            label?.numberOfLines = 0  // the KEY to making it wrap, otherwise default is 1 line that goes off edge of screen
        }
        else{
            label = SKLabelNode(text:"Hello monostyle world")
        }
        if let label = label {
            label.verticalAlignmentMode = .center
            // because we haven't added it in the GameScene visual editor, need to add manually
            scene?.addChild(label)
            if fadeIn {
                label.alpha = 0.0
                label.run(SKAction.fadeIn(withDuration: 2.0))
            }
        }
        return label
    }
    
    func makeMonoLabel(on scene:SKScene?, fadeIn:Bool, wrapWidth:CGFloat) -> SKLabelNode? {
        var label: SKLabelNode? = nil
        
        if #available(iOS 11.0, *) {
            let mas = monostyledAS(from: "This is a nice bit of text")
            label = SKLabelNode(attributedText: mas)
            // WARNING our label will NOT wrap to fit by default, make it wrap using these calls possibly introduced in iOS 11
            label?.lineBreakMode = .byWordWrapping
            label?.numberOfLines = 0  // the KEY to making it wrap, otherwise default is 1 line that goes off edge of screen
        }
        else{
            label = SKLabelNode(text:"Hello monostyle world")
        }
        if let label = label {
            label.preferredMaxLayoutWidth = wrapWidth //ALSO ENABLES LINE WRAPPING
            //var labelVert = label.frame.height/2.0
            // because we haven't added it in the GameScene visual editor, need to add manually
            label
            scene?.addChild(label)
            if fadeIn {
                label.alpha = 0.0
                label.run(SKAction.fadeIn(withDuration: 2.0))
            }
        }
        return label
    }

    func makeTopBottomLabelNodes(on scene:SKScene?, fadeIn:Bool=false) -> [SKLabelNode?] {
        guard let sc = scene else { return [] }
        let indentedWrap = sc.frame.width - 24.0
        let top = makeMonoLabel(on: scene, fadeIn: fadeIn, wrapWidth: indentedWrap)
        top?.position = CGPoint(x: 0, y: sc.frame.height + sc.frame.minY)  // adjust position AFTER adding
        top?.verticalAlignmentMode = .top
        let animColors = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 4)
        top?.run(animColors)
        
        let bottom = makeMonoLabel(on: scene, fadeIn: fadeIn, wrapWidth: indentedWrap)
        bottom?.position = CGPoint(x: 0, y: sc.frame.minY)  // adjust position AFTER adding
        bottom?.verticalAlignmentMode = .bottom
        return [top, bottom]
    }

    
    /// use a UILabel so can put annotated string in regardless of version
    func makeUILabelOverlay(on scene:SKScene?) -> UILabel? {
        let viewframeSize = scene?.view?.frame.size ?? CGSize(width:200, height:200)
        let labelView = UILabel(frame: CGRect(origin: CGPoint(), size:viewframeSize))
        labelView.attributedText = fancyHello()
        labelView.lineBreakMode = .byWordWrapping
        labelView.numberOfLines = 0
        scene?.view?.addSubview(labelView)
        return labelView
    }
    
    // SLOOOOWWW to render compared to attributed string
    func makeWebView(sizedTo scene:SKScene?, background bgColorString:String) -> WKWebView  {
        let viewframeSize = scene?.view?.frame.size ?? CGSize(width:200, height:200)
        let hview = WKWebView(frame: CGRect(origin: CGPoint(), size:viewframeSize))
        // using very simple way to centre vertically with big margin
        hview.loadHTMLString("""
        <html>
        <style>
            body {background-color: \(bgColorString);  display: flex; justify-content: center;align-items: center; }
            section{ display: grid; }
        </style>
        <body>
        <section>
        <div class="vc" style="color:cyan;text-align: center;font-size: 10vw ">Hello Webbie World</div>
        <div class="vc" style="color:darkgoldenrod;text-align: center;font-size: 10vw ">I <i>like</i> HTML</div>
        </section>
        </body>
        </html>
        """
            , baseURL: nil)
        hview.scrollView.isScrollEnabled = false  // FORCE RENDERING SCALED WITHIN THE WINDOW
        hview.isUserInteractionEnabled = false
        return hview
    }
    
    // Slow and swallows gestures
    func makeWebOverlay(on scene:SKScene?) -> WKWebView?  {
        let hview = makeWebView(sizedTo: scene, background:"rgba(0,50,50,1)")
        // as an overlay, want it see-through
        hview.scrollView.isOpaque = false
        hview.isOpaque = false
        hview.backgroundColor = UIColor.clear
        hview.scrollView.backgroundColor = UIColor.clear
        scene?.view?.addSubview(hview)
        return hview
    }
    
    func makeWebUnderlay(on scene:SKScene?) -> WKWebView?  {
        let hview = makeWebView(sizedTo: scene, background:"rgba(247,135,223,1)")
        scene?.view?.superview?.insertSubview(hview, at: 0) // put behind the scene
        scene?.makeTransparent()
        return hview
    }

    // Slow and broken but leaves us in pure SpriteKit world
    func makeWebImage(on scene:SKScene?) -> WebviewImageCapturer?  {
        let hview = makeWebView(sizedTo: scene, background:"rgba(244,247,185,1)")
        // two-stage process as we cannot capture its image until it loads and renders
        let imageGrabber = WebviewImageCapturer(scene:scene!)
        hview.navigationDelegate = imageGrabber
        scene?.view?.addSubview(hview)
        return imageGrabber
    }

}  // enum TextDisplay


class GameScene: SKScene {
    
    private var display = TextDisplay.nothing
    private var spinnyNode: SKShapeNode?
    
    override func didMove(to view: SKView) {
        display = display.addNext(on:self)
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
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        display = display.addNext(on:self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}  // GameScene

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

func monostyledAS(from:String) -> NSAttributedString {
    let myString = NSMutableAttributedString(string:from)
    // Declare the fonts
    let myStringFont1 = UIFont(name:"Noteworthy-Bold", size:96.0)!
    let myStringRange1 = NSRange(location: 0, length: myString.length)
    
    // Declare the colors
    myString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.yellow, range:myStringRange1)
    myString.addAttribute(NSAttributedString.Key.font, value:myStringFont1, range:myStringRange1)
    myString.addAttribute(NSAttributedString.Key.strokeColor, value:UIColor.green, range:myStringRange1)
    myString.addAttribute(NSAttributedString.Key.strokeWidth, value:-6.0, range:myStringRange1)
    // the following by itself does NOT make it wrap
    let myStringParaStyle1 = NSMutableParagraphStyle()
    myStringParaStyle1.alignment = NSTextAlignment.center
    myString.addAttribute(NSAttributedString.Key.paragraphStyle, value:myStringParaStyle1, range:myStringRange1)
    
    return NSAttributedString(attributedString:myString)
}

