//
//  GameViewController.swift
//  ShapeScribble macOS
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {
  
    @IBOutlet weak var optionSeg: NSSegmentedControl!
    @IBOutlet weak var varyColorsCheck: NSButton!
    var varColorsOn:Bool {get { return varyColorsCheck.state == .on  }}
    
    // via Attributed String Creator
    let coloredLabel =  NSMutableAttributedString(string:"Vary colors per stroke")
    
    // Declare the fonts
    let coloredLabelFont1 = NSFont(name:"SFUIDisplay-Regular", size:14.0)!
    
    // Declare the colors
    let coloredLabelColor1 = NSColor(red: 0.292745, green: 0.461693, blue: 0.998524, alpha: 1.000000)
    let coloredLabelColor2 = NSColor(red: 0.999999, green: 0.999974, blue: 0.999991, alpha: 1.000000)
    
    
    lazy var skView = self.view as! SKView
    lazy var scene: SKScene = SKScene()
    
    @IBAction func clearDrawing(_ sender: Any) {
          makeScene(sceneIndex:optionSeg.selectedSegment)
    }

    @IBAction func optionSegChanged(_ sender: Any) {
        makeScene(sceneIndex:optionSeg.selectedSegment)
    }

    @IBAction func varyColorsValueChange(_ sender: Any) {
// remake the scene if index 0
        if optionSeg.selectedSegment == 0 {
            makeScene(sceneIndex:0)
        }
    }
    
    func makeScene(sceneIndex:Int) {
        var strokeColorMaker = varColorsOn ? ColorProvider() : ColorProvider(fixedColor: .green)
        switch sceneIndex {
        case 0:
            scene = GameScene2LineNodes.newGameScene(strokeColors: strokeColorMaker)
            
        case 1:
            scene = GameScenePathRebuilding.newGameScene(strokeColors: strokeColorMaker)
            
        default:
            scene = GameSceneParticleCrayon.newGameScene(strokeColors: strokeColorMaker)
        }
        skView.presentScene(scene)
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        makeScene(sceneIndex:optionSeg.selectedSegment)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        // Create the attributes and add them to the string
        coloredLabel.addAttribute(NSAttributedString.Key.font, value:coloredLabelFont1, range:NSRange(location: 0, length: 22))
        coloredLabel.addAttribute(NSAttributedString.Key.underlineColor, value:coloredLabelColor1, range:NSRange(location: 0, length: 22))
        coloredLabel.addAttribute(NSAttributedString.Key.foregroundColor, value:coloredLabelColor2, range:NSRange(location: 0, length: 22))
        coloredLabel.addAttribute(NSAttributedString.Key.underlineStyle, value:1, range:NSRange(location: 0, length: 22))
        varyColorsCheck.attributedTitle = coloredLabel
    }

}

