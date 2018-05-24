//
//  GameViewController.swift
//  ShapeScribble iOS
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  @IBAction func clearDrawing(_ sender: Any) {
    scene.clear()
  }
  
  @IBOutlet weak var optionSeg: UISegmentedControl!
  @IBOutlet weak var skView: SKView!
  
  lazy var scene:GameScene = GameScene.newGameScene()
  
  override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene.newGameScene()

        // Present the scene
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
