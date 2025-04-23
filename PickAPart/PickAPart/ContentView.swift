//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var isShowingSpriteKit = false
    
    var body: some View {
        VStack {
            Spacer()
            Button((isShowingSpriteKit ? "Hide " : "Show ") + "SpriteKit Demos") {
                isShowingSpriteKit.toggle()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            if isShowingSpriteKit {
                SKViewWithResizes()
            } else {
                Text("Dummy view so can easily breakpoint the SpriteKit stuff after launch and see dismantleView being invoked")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
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

