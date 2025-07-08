//
//  SpriteKitContainerWithGen.swift
//  VidExies
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


// simple ref class to own a view made in here, so caller can pass around
// much like what happens inside Coordinator but exposed at higher level
class SKViewOwner {
    typealias Resizer = (CGSize, CGSize) -> Void
    public let id = UUID()
    public var ownedView: LayoutSensingSKView? = nil
    public var resizer: Resizer? = nil
}

// Container taking a generator function, expects to only show one scene
// Tries to be fairly reusable so parameterised with a couple of lambdas
struct SpriteKitContainerWithGen : AgnosticViewRepresentable {
    
#if DEBUG
    private let id = UUID()
#endif

    typealias RepresentedViewType = SKView
    let sceneMaker: ResizeableSceneMaker
    let playsOn: SKViewOwner

    // memoizes state to be passed back in via updateView context
    class Coordinator: NSObject {
        let coordId = UUID()
        var isFirstScene: Bool!
        var lastViewSize = CGSize.zero
        let sceneMaker: ResizeableSceneMaker
        let playsOn: SKViewOwner

        init(maker: ResizeableSceneMaker, playsOn: SKViewOwner) {
            self.sceneMaker = maker
            self.playsOn = playsOn
            self.isFirstScene = playsOn.ownedView == nil  // avoid recreation == restart
            print("SpriteKitContainerWithGen.Coordinator \(coordId) init")
        }
        
        func cleanup() {
            sceneMaker.forgetScene()
            playsOn.ownedView = nil
            print("cleanup of SKViewOwner id \(playsOn.id.uuidString)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        print("SpriteKitContainerWithGen \(id) makeCoordinator")
        return Coordinator(maker: self.sceneMaker, playsOn: self.playsOn)
    }
    
    func makeView(context: Context) -> SKView {
        var ret: LayoutSensingSKView
        if let keptView = playsOn.ownedView {
            ret = keptView // don't recreate the SKView
        } else {
            ret = LayoutSensingSKView(frame: .zero)
            playsOn.ownedView = ret
            print("SKView created for SKViewOwner id \(playsOn.id.uuidString)")
        }
        playsOn.resizer = { (oldSize: CGSize, newSize: CGSize) in
            sceneMaker.viewResized(from: oldSize, to: newSize)}
        ret.onLayout = { (skv: SKView) in
            guard skv.hasSize else {
                print("onLayout called with zero size view")
                return
            }
            if context.coordinator.isFirstScene {
                skv.presentScene(sceneMaker.makeScene(sizedTo: skv.bounds.size))
                context.coordinator.isFirstScene = false
                context.coordinator.lastViewSize = skv.bounds.size
                print("onLayout sbout to presentScene size \(skv.bounds.size) for first scene")
            } else {
                guard skv.scene != nil else {
                    print("onLayout not adjusting when not presenting a scene")
                    return
                }
                let newSize = skv.bounds.size
                let oldSize = context.coordinator.lastViewSize
                if newSize != oldSize {
                    print("onLayout resized from (\(oldSize.width),  \(oldSize.height)) to (\(newSize.width), \(newSize.height)")
                    context.coordinator.lastViewSize = newSize
                    sceneMaker.viewResized(from: oldSize, to: newSize)
                } else {
                    print("onLayout called for SKView after first scene started")  // probably recreated view hierarchy
                }
            }
        }
        return ret
    }
    
    // triggered on first load and then re-triggered because dependency on @State sceneIndex which may be altered externally
    func updateView(_ view: SKView, context: Context) {
        if context.coordinator.isFirstScene {
            if view.hasSize {
                print("updateView invoked with size, about to presentScene(makeScene())")
                // Now that we have the size, we can set up the scene
                view.presentScene(sceneMaker.makeScene(sizedTo: view.bounds.size))
                context.coordinator.isFirstScene = false
                context.coordinator.lastViewSize = view.frame.size
            } else {
                // Layout hasn't occurred yet, schedule the scene presentation for later
                print("updateView first scene has no size so leave for onLayout to start")
                    }
        } else {
            // tempting to think we can capture a resize here but only place detecting a resize is onLayout
           // print("updateView invoked after first scene setup, view size currently \(view.bounds.size)")
            // note when exporting framewise this is hit every frame
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
        print("dismantleView invoked in SpriteKitContainerWithGen for Coordinator \(coordinator.coordId)")
        view.presentScene(nil)
        // don't as could be dismantling because it's beeen hidden to show a framewise preview
        // coordinator.cleanup()
    }
    
}

extension SKView {
    var hasSize: Bool {get{
        let sz = self.frame.size
        return !sz.width.isZero && !sz.height.isZero
    }}
}
