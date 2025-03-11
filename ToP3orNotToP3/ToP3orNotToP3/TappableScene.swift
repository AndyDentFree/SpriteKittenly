//
//  Untitled.swift
//  ToP3orNotToP3
//
//  Created by Andrew Dent on 11/3/2025.
//

import SpriteKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class TappableScene: SKScene {
    var shapeColorProvider: () -> SKColor
    
    init(size: CGSize, shapeColorProvider: @escaping () -> SKColor) {
        self.shapeColorProvider = shapeColorProvider
        super.init(size: size)
        self.scaleMode = .resizeFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
#if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        makeShape(at: touch.location(in: self))
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        makeShape(at: event.location(in: self))
    }
#endif
    
    private func makeShape(at location: CGPoint) {
        // Create a circle shape node.
        let radius: CGFloat = 30.0
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = location
        
        // Use the closure to set the fill color dynamically.
        circle.fillColor = shapeColorProvider()
        circle.strokeColor = .clear
        addChild(circle)
    }
}
