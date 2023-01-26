//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let scenes = [SKScene(fileNamed: "Scene1")!,  SKScene(fileNamed: "Scene2")!]
    @State var sceneIndex = 0
    var body: some View {
        VStack {
            SpriteView(scene: scenes[sceneIndex])
            Button("Toggle Scene to \(2 - sceneIndex)") {
                sceneIndex = 1 - sceneIndex
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
