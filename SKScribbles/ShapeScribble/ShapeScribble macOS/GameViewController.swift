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
  lazy var skView = self.view as! SKView
  lazy var scene: SKScene = GameScene2LineNodes.newGameScene()

  @IBAction func clearDrawing(_ sender: Any) {
      makeScene(sceneIndex:optionSeg.selectedSegment)
  }
  
  @IBAction func optionSegChanged(_ sender: Any) {
    makeScene(sceneIndex:optionSeg.selectedSegment)
  }

    func makeScene(sceneIndex:Int) {
        if sceneIndex == 0 {
            scene = GameScene2LineNodes.newGameScene()
        }
        else {
            scene = GameScenePathRebuilding.newGameScene()
        }
        skView.presentScene(scene)
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        makeScene(sceneIndex:optionSeg.selectedSegment)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}

