//
//  MacGameViewController.swift
//  ShapeScribble macOS
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class MacGameViewController: NSViewController {
  @IBOutlet weak var gameView: SKView!
  @IBOutlet weak var optionSeg: NSSegmentedControl!
  
  @IBAction func clearDrawing(_ sender: Any) {
    scene.clear()
  }
  
  lazy var scene:GameScene = GameScene.newGameScene()

  override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene.newGameScene()
        
        // Present the scene
        gameView.presentScene(scene)
        
        gameView.ignoresSiblingOrder = true
        
        gameView.showsFPS = true
        gameView.showsNodeCount = true
    }

}

