//
//  ColorProvider.swift
//  ShapeScribble
//
//  Created by ad on 18/3/19.
//  Copyright © 2019 Touchgram Pty Ltd. All rights reserved.
//

import Foundation
import SpriteKit

// note that SKColor is an Apple typedef to work as NSColor on macOS, UIColor elsewhere
public func ColorProvider(fixedColor:SKColor?=nil) ->  AnyIterator<SKColor> {
    // see https://medium.com/@cgoldsby/swift-the-never-ending-rainbow-7e2471d9ac3
    // and inspiration https://krazydad.com/tutorials/makecolors.php
    if fixedColor == nil {
        return SKColor.rainbowIterator(frequency: 0.1, phase1: 0.0, phase2: 2.0, phase3: 4.0, amplitude: 128.0, center: 128.0, repeat: true)
    }
    
    return AnyIterator {
        return fixedColor!
    }
}
