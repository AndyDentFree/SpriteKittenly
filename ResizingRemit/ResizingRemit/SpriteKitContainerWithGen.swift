//
//  SpriteKitContainerWithGen.swift
//  ResizingRemit
//
//  Created by AndyDent on 27/1/2023.
//


import SpriteKit
import SwiftUI


protocol ResizeableSceneMaker {
    func makeScene(sizedTo: CGSize) -> SKScene
    func viewResized(from oldSize: CGSize, to newSize: CGSize)
    func forgetScene()
}


// Container taking a generator function, expects to only show one scene
// Tries to be fairly reusable so parameterised with a couple of lambdas
struct SpriteKitContainerWithGen : AgnosticViewRepresentable {
    
    typealias RepresentedViewType = SKView
    let sceneMaker: ResizeableSceneMaker
    
    // memoizes state to be passed back in via updateUIView context
    class Coordinator: NSObject {
        var isFirstScene = true
        var lastViewSize = CGSize.zero
        var sceneMaker: ResizeableSceneMaker
        
        init(maker: ResizeableSceneMaker) {
            self.sceneMaker = maker
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(maker: self.sceneMaker)
    }
    
    func makeView(context: Context) -> SKView {
        let ret = LayoutSensingSKView(frame: .zero)
        ret.onLayout = {
            guard $0.hasSize else {
                print("onLayout called with zero size view")
                return
            }
            if context.coordinator.isFirstScene {
                context.coordinator.lastViewSize = $0.frame.size
                print("onLayout saving size for first scene")
            } else {
                let newSize = $0.bounds.size
                let oldSize = context.coordinator.lastViewSize
                if newSize != oldSize {
                    print("onLayout resized from (\(oldSize.width),  \(oldSize.height)) to (\(newSize.width), \(newSize.height)")
                    context.coordinator.lastViewSize = newSize
                    sceneMaker.viewResized(from: oldSize, to: newSize)
                } else {
                    print("onLayout called for SKView after first scene started")
                }
            }
        }
        return ret
    }
    
    // triggered on first load and then re-triggered because dependency on @State sceneIndex which may be altered externally
    func updateView(_ view: SKView, context: Context) {
        if context.coordinator.isFirstScene {
            if view.hasSize {
                print("updateView invoked with size, about to makeScene")
                // Now that we have the size, we can set up the scene
                view.presentScene(sceneMaker.makeScene(sizedTo: view.bounds.size))
                context.coordinator.isFirstScene = false
                context.coordinator.lastViewSize = view.frame.size
            } else {
                // Layout hasn't occurred yet, schedule the scene presentation for later
                print("updateView first scene has no size so defer to async")
                DispatchQueue.main.async {
                    if view.hasSize {
                        print("updateView invoked async now with size, about to makeScene")
                        view.presentScene(sceneMaker.makeScene(sizedTo: view.bounds.size))
                        context.coordinator.isFirstScene = false
                    } else {
                        print("updateView deferred async still has no size so give up")  // never hits this case
                    }
                }
            }
        } else {
            // tempting to think we can capture a resize here but only place detecting a resize is onLayout
            print("updateView invoked after first scene setup, view size currently \(view.bounds.size)")
        }
    }
 /*
    // uncomment just to see callbacks
    @MainActor @preconcurrency
    func sizeThatFits(_ proposal: ProposedViewSize, view: RepresentedViewType, context: Context) -> CGSize?
    {
        print("sizeThatFits - Prop size (\(proposal.width ?? -1.0), \(proposal.height ?? -1.0))")
        return nil  // use default
    }
 */
    
    static func dismantleView(_ view: RepresentedViewType, coordinator: Self.Coordinator) {
        print("dismantleView invoked in SpriteKitContainerWithGen")
        coordinator.sceneMaker.forgetScene()
        view.presentScene(nil)
    }
    
}

extension SKView {
    var hasSize: Bool {get{
        let sz = self.frame.size
        return !sz.width.isZero && !sz.height.isZero
    }}
}