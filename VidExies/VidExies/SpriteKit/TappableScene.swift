//
//  TappableScene.swift
//  VidExies
//
//  Created by Andy Dent on 19/3/2025.
//

import SpriteKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class TappableScene: SKScene {
    var onTouch: ()->Void

    init(size: CGSize, onTouch: @escaping () -> Void) {
        self.onTouch = onTouch
        super.init(size: size)
        self.scaleMode = .resizeFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
#if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }
        onTouch()
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        onTouch()
    }
#endif
}
