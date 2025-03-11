//
//  SKViewWithResizes.swift
//  ToP3orNotToP3
//
//  Created by AndyDent on 27/1/2023.
//


import SpriteKit
import SwiftUI

/// Show a single scene with expansion of the view triggered in SwiftUI
struct SKViewWithResizes: View {
    @State var expandedSKView = false
    
    var body: some View {
        VStack {
            SpriteKitContainerWithGen(sceneMaker: EmitterSceneMaker())
                .frame(minHeight: 100,  maxHeight: .infinity)
            Button("Toggle height") {
                expandedSKView.toggle()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Text("Pressing Toggle height should move emitters so stay same relative to scene")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: expandedSKView ? 20 : 300)
        }
        .padding()
    }
}


// so we can preview just the SKView
struct SKViewWithResizes_Previews: PreviewProvider {
    static var previews: some View {
        SKViewWithResizes()
    }
}

