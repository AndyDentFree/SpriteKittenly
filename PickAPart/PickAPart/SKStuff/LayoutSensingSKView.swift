//
//  LayoutSensingSKView.swift
//  PickAPart
//
//  Created by Andrew Dent on 3/12/2024.
//


import SpriteKit
import SwiftUI

// helper class so can invoke a lambda onLayout, typically when SKView has been resized
class LayoutSensingSKView: SKView {
    
    @MainActor
    var onLayout: ((SKView) -> Void)!
    
    #if os(iOS)
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
    #elseif os(macOS)
    override func layout() {
        super.layout()
        onLayout?(self)
    }
    #endif
}
