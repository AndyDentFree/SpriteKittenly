//
//  TemplateView.swift
//  PickAPart
//
//  Created by Andrew Dent on 1/5/2025.
//

import SwiftUI
import SpriteKit

/// Sample running a tiny touchgram to show an emitter
struct TemplateView: View {
    @Binding var model: TemplateModel

    var body: some View {
        VStack{
            SpriteKitContainerWithGen(sceneMaker: model.maker)
                .padding(.zero)
            HStack(alignment: .center) {
                Text(model.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(4)
            } // HStack for badging
            .background(model.isSelected ? Color.blue.opacity(0.7) : Color.clear)
        }
    }
}

struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TemplateView(model: .constant(TemplateModel(templateIndex: 9)))
            Spacer()
            TemplateView(model: .constant(TemplateModel(templateIndex: 13, isSelected: true)))
        }
        .frame(maxHeight: 160)
        .padding()
    }
}
