//
//  PlayViewController.swift
//  SKShaderToy
//
//  Created by AndyDent on 5/4/21.
//

import UIKit
import SpriteKit

class PlayViewController: UIViewController {
    @IBOutlet weak var playView: SKView!
    lazy var model:SKShaderToyModel? = AppDelegate.model


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            model?.startPlaying(onView: view)        }
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
