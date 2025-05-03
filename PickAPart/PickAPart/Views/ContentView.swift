//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink("Fake an existing document") { makeViewWithEmitters(asNew: false) }
                Spacer()
                NavigationLink("Fake a new document with picker") { makeViewWithEmitters(asNew: true) }
                Spacer()
                Text("Initial view would be document browser in a true document app.")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .navigationBarTitle("Fake doc browser")
    }
    
    private func makeViewWithEmitters(asNew: Bool = true) -> PaPView {
        PaPView(id: UUID(), doc: PapDocument.makeDoc(asNew: asNew))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

