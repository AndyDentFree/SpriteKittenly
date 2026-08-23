//
//  PaPView.swift
//  PickAPart
//
//  Created by Andrew Dent on 24/4/2025.
//

import SwiftUI

/// Shows a picker for document template, which is a grid of templates, or a full preview from that template
struct PaPView: View {
    let id: UUID  // use to force new creation
    @State var doc: PapDocument
    
    var body: some View {
        if doc.needsPicker {  // no template yet specified
            TemplatePickerView(document: $doc)
        } else {
            PreviewView(doc: $doc)
        }
    }
}

/*
#Preview {
    PaPView()
}
*/
