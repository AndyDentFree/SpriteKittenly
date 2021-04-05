//
//  PlayViewController.swift
//  SKShaderToy
//
//  Created by AndyDent on 5/4/21.
//

import UIKit
import SpriteKit

class PlayViewController: UIViewController {
    @IBOutlet var playView: SKView!
    lazy var model:SKShaderToyModel! = AppDelegate.model


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.startPlaying(onView: playView)
        if model.editDirty {
            model.editDirty = false
            model.updateShaderNode()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
