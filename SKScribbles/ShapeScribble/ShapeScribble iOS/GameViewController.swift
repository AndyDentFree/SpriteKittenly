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

    @IBOutlet weak var optionSeg: UISegmentedControl!
    @IBOutlet weak var skView: SKView!

    lazy var scene: SKScene = GameScene2LineNodes.newGameScene()

  @IBAction func segValueChange(_ sender: Any) {
      makeScene(sceneIndex:optionSeg.selectedSegmentIndex)
  }

  @IBAction func clearDrawing(_ sender: Any) {
      makeScene(sceneIndex:optionSeg.selectedSegmentIndex)
  }

  override func viewDidLoad() {
        super.viewDidLoad()

        makeScene(sceneIndex:optionSeg.selectedSegmentIndex)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    
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
