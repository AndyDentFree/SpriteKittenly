//
//  SpriteViewApproach.swift
//  SkinSuit
//
//  Created by AndyDent on 27/1/2023.
//

import SpriteKit
import SwiftUI

struct SpriteViewApproach: View {
    @StateObject var sceneFrom = SceneProvider()
    @State var withTransitions = false
    let logger = InitLogger(msg: "SpriteViewApproach")
    
    var body: some View {
        VStack {
            SpriteView(scene: sceneFrom.scene)  // initial scene only, see use of presentScene above
            HStack {
                Button("Toggle Scene to \(sceneFrom.nextScene1Based)") {
                    sceneFrom.toggleSceneIndex(withTransitions, withImmediatePresentScene: true)  // presentScene happens from this call
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Toggle("with Transitions", isOn: $withTransitions)
            }
            Text("Scene changing with SwiftUI's official wrapper: SpriteView")
        }
        .padding()
    }
}

// so we can preview just the SKView
struct SpriteViewApproach_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            SpriteView(scene: sceneMakers[0](), transition: nil)
            SpriteView(scene: sceneMakers[1](), transition: nil)
        }
    }
}

