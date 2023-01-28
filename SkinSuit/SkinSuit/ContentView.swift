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
    let transitions = [
        SKTransition.push(with: .up, duration: 2.0),
        SKTransition.push(with: .down, duration: 1.0)]
    
    var body: some View {
        TabView {
            SKViewApproach(scenes: scenes, transitions: transitions)
                .tabItem {
                    Label("Wrapped SKView", systemImage: "play.rectangle.on.rectangle")
                }
            SpriteViewApproach(scenes: scenes, transitions: transitions)
                .tabItem {
                    Label("SpriteView", systemImage: "rectangle.on.rectangle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

