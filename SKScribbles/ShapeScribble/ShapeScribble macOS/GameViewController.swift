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
  @IBAction func clearDrawing(_ sender: Any) {
    scene.clear()
  }
  
  @IBAction func optionSegChanged(_ sender: Any) {
    scene.setDrawMode(optionSeg.selectedSegment)
  }
  
  lazy var scene:GameScene = GameScene.newGameScene()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene.newGameScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}

