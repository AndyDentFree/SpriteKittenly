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

class GameViewControllerIOS: UIViewController {

    @IBOutlet weak var optionSeg: UISegmentedControl!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var varyColorsSwitch: UISwitch!
    @IBOutlet weak var fillSwitch: UISwitch!
    
    
    var varColorsOn:Bool {get { return varyColorsSwitch?.isOn ?? false  }}
    var fillOn:Bool {get { return fillSwitch?.isOn ?? false }}
    lazy var scene: SKScene = SKScene()

    @IBAction func segValueChange(_ sender: Any) {
        clearDrawing(sender)
        let enableSwitches = optionSeg.selectedSegmentIndex != 2
        varyColorsSwitch.isEnabled = enableSwitches
        fillSwitch.isEnabled = enableSwitches
    }

    @IBAction func clearDrawing(_ sender: Any) {
        makeScene(sceneIndex:optionSeg.selectedSegmentIndex)
    }
    
    @IBAction func fillValueChange(_ sender: Any) {
        // remake the scene if cares
        if optionSeg.selectedSegmentIndex != 2 {
            clearDrawing(sender)
        }
    }

    @IBAction func varyColorsValueChange(_ sender: Any) {
        // remake the scene if cares
        if optionSeg.selectedSegmentIndex != 2 {
            clearDrawing(sender)
        }
    }

  override func viewDidLoad() {
        super.viewDidLoad()

        makeScene(sceneIndex:optionSeg.selectedSegmentIndex)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

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
