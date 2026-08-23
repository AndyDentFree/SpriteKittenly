//
//  TemplatePickerModel.swift
//  PickAPart
//
//  Created by Andrew Dent on 27/4/2025.
//

import Foundation

struct TemplatePickerModel {
    private var selectedItemIndex: Int? = nil
    var templates: [TemplateModel] =
    PapDocument.indexRange.map { TemplateModel(templateIndex: $0) }
    
    var selected: TemplateModel? {get{
        guard let i = selectedItemIndex else {return nil}
        return templates[i]
    }}
    
    var hasSelection: Bool {get{
        selectedItemIndex != nil
    }}

    func stopAll() {
        templates.forEach{
            $0.stopPlaying()
        }
    }

    mutating func toggleSelection(for selIndex: Int) {
        if let oldSel = selectedItemIndex {
            templates[oldSel].setSelected(false)
            if oldSel == selIndex {
                // just turned it off, tapped sole selection
                selectedItemIndex = nil
                return
            }
        }
        selectedItemIndex = selIndex
        templates[selIndex].setSelected(true)
    }
}
