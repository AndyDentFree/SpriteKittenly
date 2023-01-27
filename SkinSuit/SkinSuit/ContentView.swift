//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let scenes = [SKScene(fileNamed: "Scene0")!,  SKScene(fileNamed: "Scene1")!].map{
        $0.scaleMode = .aspectFill
        return $0
    }
    @State var sceneIndex = 0
    @State var isFirstScene = true
    let gotoScene0 = SKTransition.push(with: .up, duration: 2.0)
    let gotoScene1 = SKTransition.push(with: .down, duration: 1.0)
    var body: some View {
        VStack {
            if isFirstScene {
                SpriteView(scene: scenes[0])
            } else {
                if sceneIndex == 1 {  // going to 1
                    SpriteView(scene: scenes[1], transition: gotoScene1)
                } else {
                    SpriteView(scene: SKScene(fileNamed: "Scene0")!, transition: gotoScene0)
  // BUG IF REUSE SpriteView(scene: scenes[0], transition: gotoScene0)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
