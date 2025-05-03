//
//  PreviewView.swift
//  PickAPart
//
//  Created by Andrew Dent on 30/4/2025.
//


import SwiftUI

/// Shows a picker for document template, which is a grid of templates, or a full preview from that template
struct PreviewView: View {
    @Binding var doc: PapDocument
    
    var body: some View {
        SpriteKitContainerWithGen(sceneMaker: EmitterSceneMaker(emIndex: doc.selectedEmitterIndex))
    }
}

#Preview {
    PreviewView(doc: .constant(PapDocument.makeDoc(templateIndex: 8)))
}

