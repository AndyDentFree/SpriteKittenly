//
//  SceneProvider.swift
//  SkinSuit
//
//  Created by Andy Dent on 1/4/2025.
//

import SwiftUI
import SpriteKit

// helper that takes care of presenting the next scene
final class SceneProvider: ObservableObject {
    @Published var scene: SKScene
    private(set) var sceneIndex: Int
    var nextScene1Based: Int {2 - sceneIndex}  // for display
    var nextPresentWithTransition = false
    
    init(initialIndex: Int = 0) {
        sceneIndex = initialIndex
        scene = sceneMakers[sceneIndex]()
    }
    
    func toggleSceneIndex(_ transitionToNext: Bool, withImmediatePresentScene: Bool) {
        sceneIndex = 1 - sceneIndex
        nextPresentWithTransition = transitionToNext
        if withImmediatePresentScene {
            guard let skv = scene.view else {
                print("Unable to present next scene as SKScene lacks reference to its SKView")
                return
            }
            scene = sceneMakers[sceneIndex]()
            presentScene(refreshing: skv)
        } else {
            scene = sceneMakers[sceneIndex]()
        }
    }
    
    func presentScene(refreshing skv: SKView) {
        if nextPresentWithTransition {  // use property to remember from the UI call that triggered refresh
            skv.presentScene(scene, transition: transitionMakers[sceneIndex]())
        } else {
            skv.presentScene(scene)
        }
    }

}
