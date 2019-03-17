//
//  ColorIterator.swift
//  Sequences
//
//  License
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import SpriteKit

private let π = CGFloat(Double.pi)
private let 𝟤π = 2 * π

public enum Default {
    
    public static let phase1:      CGFloat = 0         // 0 °
    public static let phase2:      CGFloat = 2 * π / 3 // 120°
    public static let phase3:      CGFloat = 4 * π / 3 // 240°
    public static let frequency:   CGFloat = 0.3
    public static let amplitude:   CGFloat = 255 / 2
    public static let center:      CGFloat = 255 / 2
}

extension SKColor {
    
    /// http://krazydad.com/tutorials/makecolors.php
    
    /**
     Generates the `next` color using a Sine wave.
     - returns: `AnyIterator<UIColor>`
     - parameter frequency: how fast the sine wave oscillates
     - parameter phase1: color phase in radians for red
     - parameter phase2: color phase in radians for green
     - parameter phase3: color phase in radians for blue
     - parameter amplitude: how high and low the sine wave reaches.
     - parameter center: the center position of the sine wave.
     - parameter repeat: if `true` the sequence will continue infinitely; defaults to false
     */
    public static func rainbowIterator(frequency:  CGFloat = Default.frequency,
                                       phase1:     CGFloat = Default.phase1,
                                       phase2:     CGFloat = Default.phase2,
                                       phase3:     CGFloat = Default.phase3,
                                       amplitude:  CGFloat = Default.amplitude,
                                       center:     CGFloat = Default.center,
                                       repeat:     Bool    = false) -> AnyIterator<SKColor> {
        var iteration = 0
        
        return AnyIterator {
            let didRepeat = ShapeScribble.didRepeat(frequency: frequency, iteration: iteration)
            
            guard `repeat` || !didRepeat else { return nil }
            
            if didRepeat {
                iteration = 0 // Reset iteration count after completing a sine wave.
            }
            
            let r = sin(frequency: frequency, iteration: iteration, phase: phase1, amplitude: amplitude, center: center)
            let g = sin(frequency: frequency, iteration: iteration, phase: phase2, amplitude: amplitude, center: center)
            let b = sin(frequency: frequency, iteration: iteration, phase: phase3, amplitude: amplitude, center: center)
            
            iteration += 1
            
            return SKColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
        }
    }
}

/// General equation for calculating the sine.
private func sin(frequency:   CGFloat,
                 iteration:   Int,
                 phase:       CGFloat,
                 amplitude:   CGFloat,
                 center:      CGFloat) -> CGFloat {
    
    return sin(frequency * CGFloat(iteration) + phase) * amplitude + center
}

/// Given the frequency and iteration has the sine wave completed at least one cycle.
private func didRepeat(frequency: CGFloat, iteration: Int) -> Bool {
    return frequency * CGFloat(iteration) > 𝟤π
}
