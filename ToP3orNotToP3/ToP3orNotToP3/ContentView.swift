//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State fileprivate var NextShapeColor = Color.red
    
    var body: some View {
        VStack {
            Spacer()
            SpriteKitContainerWithGen(sceneMaker: ColoredShapeSceneMaker(colored: {$NextShapeColor.wrappedValue}))
                .frame(minHeight: 100,  maxHeight: .infinity)
            Spacer()
            Group{
                Text("Pick a color and try varying between P3 and sRGB color spaces")
                HStack {
                    ColorPicker("Next shape color", selection: $NextShapeColor)
                }
            }
            .padding(.horizontal)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

