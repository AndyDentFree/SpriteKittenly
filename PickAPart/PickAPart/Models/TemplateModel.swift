//
//  TemplateModel.swift
//  PickAPart
//
//  Created by Andrew Dent on 1/5/2025.
//


import Foundation

struct TemplateModel: Identifiable {
    let templateIndex: Int
    let maker: EmitterSceneMaker
    var isSelected: Bool
    var title: String { maker.title }
    var id: UUID { UUID() }
    
    init(templateIndex: Int, isSelected: Bool = false) {
        self.templateIndex = templateIndex
        self.isSelected = isSelected
        maker = EmitterSceneMaker(emIndex: templateIndex)
    }
        
    mutating func setSelected(_ flag: Bool) {
        isSelected = flag
    }
    
    func stopPlaying() {
        maker.forgetScene()
    }
}
