//
//  TemplatePickerView.swift
//  PickAPart
//
//  Created by Andrew Dent on 27/4/2025.
//

import SwiftUI

struct TemplatePickerView: View {
    @State var pickFrom = TemplatePickerModel()
    @Binding var document: PapDocument
    
    // Flexible columns that adjust based on available space
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 100)) // Adaptive column with a minimum width of 100 points
    ]

    var body: some View {
        VStack{
            HStack{
                Text("Pick a template:")
                    .font(.title2)
                Spacer()
                Button("Edit", systemImage: "square.and.pencil", action: {
                    pickFrom.stopAll()
                    document.edit(template: pickFrom.selected)
                })
                .disabled(pickFrom.hasSelection == false)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            Divider()
            ScrollView {
                LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                    ForEach(0..<pickFrom.templates.count, id:\.self) { index in
                        TemplateView(model: $pickFrom.templates[index])
                            .onTapGesture {
                                pickFrom.toggleSelection(for: index)
                            }
                            .frame(height: 140)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    TemplatePickerView(document: .constant(PapDocument.makeDoc(templateIndex: 3)))
}
