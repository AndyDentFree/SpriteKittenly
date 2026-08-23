//
//  PapDocument.swift
//  PickAPart
//
//  Created by Andrew Dent on 23/4/2025.
//

import SpriteKit
import SwiftUI

fileprivate let maxIndex = 15

// cache stuff in a ref class so can have some state changes without struct mutation
fileprivate class EmHelper {
    var em: SKEmitterNode?  = nil // only safe AFTER a given TG starts playing!!!!
}

// PurrticlesDocument is a full FileDocument but trying to keep this example simplified
// it only needs to remember the index used to generate the emitter, which will be
// key to how EmitterSceneMaker
struct PapDocument {
    private var mh = EmHelper()  // holds all our mutable state
    private var fromTemplateIndex: Int?
    var needsPicker : Bool {fromTemplateIndex == nil}
    var selectedEmitterIndex: Int {
        guard let safeIndex = fromTemplateIndex, safeIndex <= maxIndex else {
            fatalError("Shouldn't be trying to get selectedEmitterIndex on default doc")
        }
        return safeIndex
    }
    
    init(fromTemplateIndex: Int? = nil) {
        self.fromTemplateIndex = fromTemplateIndex
    }
    
    static let indexRange = 0...maxIndex
    
    public static func makeDoc(templateIndex: Int? = nil) -> PapDocument {
        PapDocument(fromTemplateIndex: templateIndex)
    }
    
    public static func makeDoc(asNew: Bool) -> PapDocument {
        PapDocument(fromTemplateIndex: asNew ?
                    nil :
                    Int.random(in: PapDocument.indexRange)
        )
    }
    
    mutating func edit(template: TemplateModel?) {
        fromTemplateIndex = template?.templateIndex
    }
}
