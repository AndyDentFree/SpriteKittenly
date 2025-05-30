//
//  ColoredShapeSceneMaker.swift
//  ToP3orNotToP3
//
//  Created by Andy Dent on 11/03/2025.
//  Emitter creation logic generated by https://www.purrticles.com app & tweaked slightly by hand

import SpriteKit
import SwiftUI // to get Color

typealias ColorSource = () -> (Color, Bool)  // SwiftUI.Color and flag to convertDirectly

// using a class so can have a ref instance shared between SpriteKitContainerWithGen and its nested Coordinator class
class ColoredShapeSceneMaker: ResizeableSceneMaker {
    private var colorFrom: ColorSource  // closure provides a SwiftUI Color which we will convert below
    
    init(colored colorSource: @escaping ColorSource) {
        self.colorFrom = colorSource
    }
    
    func makeScene(sizedTo: CGSize) -> SKScene {
        print("Making scene sized (\(sizedTo.width), \(sizedTo.height))")
        let ret = TappableScene(size: sizedTo, shapeColorProvider: {
            let (pickedColor, convertDirectly) = self.colorFrom()
            if convertDirectly {
#if os(iOS)
                let plat = UIColor(pickedColor)
#else
                let plat = NSColor(pickedColor)
#endif
                return plat
            }
            
            if let asCG = pickedColor.cgColor {  // Color.cgColor deprecated as of iOS 18.4 but not its equivalent in NSColor/UIColor ?
#if os(iOS)
                if let space = asCG.colorSpace {
                    if space.name == CGColorSpace.displayP3 {
                        print("iOS user chose DisplayP3, in picker")
                        print(asCG.components?.description ?? "components not available")
                        // convert to sRGB because of SpriteKit bug doing wraparound
                        if let rgbSpace = CGColorSpace(name: CGColorSpace.sRGB),
                           let asRGB = asCG.converted(to: rgbSpace, intent: .defaultIntent, options: nil) {
                            return SKColor(cgColor: asRGB)  // clean convert
                        }
                    }
                }
                return SKColor(cgColor: asCG)  // weirdly unconditional on iOS!
#else
                if let ret = SKColor(cgColor: asCG) {
                    return ret
                }
                // fall through for error condition
#endif
            }
            print("Unable to convert the picked color \(pickedColor) to a cgColor")
            return SKColor.yellow
        })
        ret.scaleMode = SKSceneScaleMode.resizeFill
        return ret
    }
    
    // take oldsize in case adjustments should scale relative to that or want to compare
    // note that the position setting here is basically just a copy of that in create methods below
    // but that might not always be the case so we don't abstract a single position setter
    func viewResized(from oldSize: CGSize, to newSize: CGSize) {
        //confetti?.position = CGPoint(x: newSize.width / 2, y: newSize.height / 2)
    }
    
    func forgetScene() {
    }
}
