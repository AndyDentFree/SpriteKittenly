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

class GameViewControllerMacOS: NSViewController {
  
    @IBOutlet weak var optionSeg: NSSegmentedControl!
    @IBOutlet weak var fillCheck: NSButton!
    @IBOutlet weak var varyColorsCheck: NSButton!
    
    var fillOn:Bool {get { return fillCheck.state == .on }}
    var varColorsOn:Bool {get { return varyColorsCheck.state == .on  }}
    
    // via Attributed String Creator
    let varyColorsLabel =  NSMutableAttributedString(string:"Vary colors per stroke")
    let fillLabel =  NSMutableAttributedString(string:"Fill")

    // Declare the fonts
    let coloredLabelFont1 = NSFont(name:"SFUIDisplay-Regular", size:14.0) ?? NSFont(name: "Arial", size: 14.0)!
    
    // Declare the colors
    let coloredLabelColor2 = NSColor(red: 0.999999, green: 0.999974, blue: 0.999991, alpha: 1.000000)
    
    
    lazy var skView = self.view as! SKView
    lazy var scene: SKScene = SKScene()
    
    @IBAction func clearDrawing(_ sender: Any) {
          makeScene(sceneIndex:optionSeg.selectedSegment)
    }

    @IBAction func optionSegChanged(_ sender: Any) {
        clearDrawing(sender)
        let enableSwitches = optionSeg.selectedSegment != 2
        varyColorsCheck.isEnabled = enableSwitches
        fillCheck.isEnabled = enableSwitches
    }

    @IBAction func fillValueChange(_ sender: Any) {
        // remake the scene if cares
        if optionSeg.selectedSegment != 2 {
            clearDrawing(sender)
        }
    }

    @IBAction func varyColorsValueChange(_ sender: Any) {
        // remake the scene if cares
        if optionSeg.selectedSegment != 2 {
            clearDrawing(sender)
        }
    }
    
    func makeScene(sceneIndex:Int) {
        let strokeColorMaker = varColorsOn ? ColorProvider() : ColorProvider(fixedColor: .green)
        switch sceneIndex {
        case 0:
            scene = GameScene2LineNodes.newGameScene(strokeColors: strokeColorMaker, fill:fillOn)
            
        case 1:
            scene = GameScenePathRebuilding.newGameScene(strokeColors: strokeColorMaker, fill:fillOn)
            
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
        varyColorsLabel.addAttribute(NSAttributedString.Key.font, value:coloredLabelFont1, range:NSRange(location: 0, length: varyColorsLabel.length))
        varyColorsLabel.addAttribute(NSAttributedString.Key.foregroundColor, value:coloredLabelColor2, range:NSRange(location: 0, length: varyColorsLabel.length))
        varyColorsCheck.attributedTitle = varyColorsLabel
        
        fillLabel.addAttribute(NSAttributedString.Key.font, value:coloredLabelFont1, range:NSRange(location: 0, length: fillLabel.length))
        fillLabel.addAttribute(NSAttributedString.Key.foregroundColor, value:coloredLabelColor2, range:NSRange(location: 0, length: fillLabel.length))
        fillCheck.attributedTitle = fillLabel
    }

}

