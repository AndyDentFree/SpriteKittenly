//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

// public makers so can use in previews
let sceneMakers: [()->SKScene] = ["Scene0", "Scene1"].map{ sceneName in
    return {
        let ret = SKScene(fileNamed: sceneName)!
        ret.scaleMode = .aspectFill
        return ret
    }
}

let transitionMakers: [()->SKTransition] = [
    {SKTransition.push(with: .up, duration: 2.0)},
    {SKTransition.push(with: .down, duration: 1.0)}
]

struct ContentView: View {
    
    @State var isShowingSpriteKit = false
    @State var wrappedSKViewIsFirst = true
    
    var body: some View {
        VStack {
            Spacer()
            Button((isShowingSpriteKit ? "Hide " : "Show ") + "SpriteKit Demos") {
                isShowingSpriteKit.toggle()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            if isShowingSpriteKit {  // tabbed sprite kit views, will dismantle if hidden
                if wrappedSKViewIsFirst {
                    TabView {
                        SKViewApproach()
                            .tabItem {
                                Label("Wrapped SKView", systemImage: "play.rectangle.on.rectangle")
                            }
                        SpriteViewApproach()
                            .tabItem {
                                Label("SpriteView", systemImage: "rectangle.on.rectangle")
                            }
                    }
                } else {  // sloppy duplication but keeps clear for this demo purpose
                    TabView {
                        SpriteViewApproach()
                            .tabItem {
                                Label("SpriteView", systemImage: "rectangle.on.rectangle")
                            }
                        SKViewApproach()
                            .tabItem {
                                Label("Wrapped SKView", systemImage: "play.rectangle.on.rectangle")
                            }
                    }

                }
            } else {
                Text("Dummy view so SKView can vanish\nto demonstrate calling\ndismantleUIView")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Toggle("Wrapped SKView is first tab", isOn: $wrappedSKViewIsFirst)
                    .padding()
                Text("Whichever is the first tab is able to do scene changes with transitions. This lets you play with that and confirm it's not about choice of tech, it's a SpriteKit bug since iOS9.")
                    .padding()
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

