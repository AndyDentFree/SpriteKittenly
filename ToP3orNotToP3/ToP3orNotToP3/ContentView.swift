//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State fileprivate var NextShapeColor = Color(red: 1.0, green: 0.0, blue: 0.0)  // using Color.red causes conversion fail if don't pick new one
    @State fileprivate var convertDirectly = true
    
    var body: some View {
        VStack {
            Spacer()
            SpriteKitContainerWithGen(sceneMaker: ColoredShapeSceneMaker(colored: {($NextShapeColor.wrappedValue, $convertDirectly.wrappedValue)}))
                .frame(minHeight: 100,  maxHeight: .infinity)
            Spacer()
            Group{
                Text("Pick a color and tap above to get dots on the SpriteKit surface. Try varying between P3 and sRGB color spaces")
                    ColorPicker("Next shape color", selection: $NextShapeColor)
                    Toggle("Convert directly to SKColor", isOn: $convertDirectly)
            }
            .padding(.horizontal)
            Spacer()
                .frame(height: 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

