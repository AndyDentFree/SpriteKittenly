//
//  SpriteViewApproach.swift
//  SkinSuit
//
//  Created by AndyDent on 27/1/2023.
//

import SpriteKit
import SwiftUI

struct SpriteViewApproach: View {
    // local state for sceneIndex so no interference testing each approach
    @State var sceneIndex = 0
    @State var isFirstScene = true
    let scenes: [SKScene]
    let transitions: [SKTransition]
    
    var body: some View {
        VStack {
            if isFirstScene {
                SpriteView(scene: scenes[0])
            } else {
                if sceneIndex == 1 {  // going to 1
                    SpriteView(scene: scenes[1], transition: transitions[1])
                } else {
                    // SpriteView(scene: SKScene(fileNamed: "Scene0")!, transition: transitions[0])
                    // BUG IF REUSE
                    SpriteView(scene: scenes[0], transition: transitions[0])
                }
            }
            Button("Toggle Scene to \(2 - sceneIndex)") {
                sceneIndex = 1 - sceneIndex
                isFirstScene = false
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Text("Scene changing with re-init of SpriteView")
        }
        .padding()
    }
}

// so we can preview just the SKView
struct SpriteViewApproach_Previews: PreviewProvider {

    static var previews: some View {
        let scenes:[SKScene] = [SKScene(fileNamed: "Scene0")!, SKScene(fileNamed: "Scene1")!].map{
            $0.scaleMode = .aspectFill
            return $0
        }
        let transitions = [
            SKTransition.push(with: .up, duration: 2.0),
            SKTransition.push(with: .down, duration: 1.0)]
        SpriteViewApproach(scenes: scenes, transitions: transitions)
    }
}

