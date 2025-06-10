//
//  SKViewApproach.swift
//  SkinSuit
//
//  Created by AndyDent on 27/1/2023.
//


import SpriteKit
import SwiftUI

/// helper class to be used in a struct so we can detect destruction
class InitLogger {
    var msg: String
    init(msg: String) {
        self.msg = msg
        print("InitLogger init - \(msg) created")
    }
    deinit {
        print("InitLogger deinit - \(msg) has been destroyed")
    }
}


// This struct will be recreated regularly but the view it owns is passed on
struct SpriteKitContainer : AgnosticViewRepresentable {
    
    typealias RepresentedViewType = SKView
    let sceneFrom: SceneProvider
    var logger = InitLogger(msg: "SKContainer")  // if you make this a let, will see this deinit then init again indicates the SpriteKitContainer struct has been recreated
    
    init(sceneFrom: SceneProvider) {
        self.sceneFrom = sceneFrom
    }
    
    // memoizes state to be passed back in via updateUIView context
    class Coordinator: NSObject {
        var isFirstScene = true
        var currentSceneIndex = -1  // use to compare so don't try to do transitions to same scene
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeView(context: Context) -> SKView {
        let ret = LayoutSensingSKView(frame: .zero)
        print("makeView has created a new SKView")
        ret.onLayout = { (skv: SKView) in
            guard skv.hasSize else {
                print("onLayout called with zero size view")
                return
            }
            if context.coordinator.isFirstScene {
                skv.presentScene(sceneFrom.scene)
                context.coordinator.isFirstScene = false
                context.coordinator.currentSceneIndex = sceneFrom.sceneIndex
                print("onLayout sbout to presentScene size \(skv.bounds.size) for first scene")
            } else {
                // see ResizingRemit for handling resizes at this point
                print("onLayout called for SKView after first scene started")
            }
        }
        return ret
    }
    
    // triggered on first load
    func updateView(_ view: SKView, context: Context) {
        if context.coordinator.isFirstScene {
            // stash even if we don't present, so if onLayout presents, knowws the scene
            if view.hasSize {
                view.presentScene(sceneFrom.scene)
                context.coordinator.isFirstScene = false
            } else {
                // Layout hasn't occurred yet, schedule the scene presentation for later
                print("updateView first scene has no size so leave for onLayout to start")
            }
        } else if context.coordinator.currentSceneIndex != sceneFrom.sceneIndex {
            sceneFrom.presentScene(refreshing: view)
            context.coordinator.currentSceneIndex = sceneFrom.sceneIndex
        }
    }
    
    static func dismantleView(_ view: RepresentedViewType, coordinator: Self.Coordinator) {
        print("dismantleView invoked in SKViewApproach")
        view.presentScene(nil)
    }
    
}

struct SKViewApproach: View {
    @StateObject var sceneFrom = SceneProvider()
    @State var withTransitions = false
    
    var body: some View {
        VStack {
            SpriteKitContainer(sceneFrom: sceneFrom)
            HStack {
                Button("Toggle Scene to \(sceneFrom.nextScene1Based)") {
                    sceneFrom.toggleSceneIndex(withTransitions, withImmediatePresentScene: false)  // presentScene will be triggered from an updateView callback
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Toggle("with Transitions", isOn: $withTransitions)
            }
            Text("Using wrapped SKView to change scene")
        }
        .padding()
    }
}


// so we can preview just the SKView
struct SKViewApproach_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            SpriteKitContainer(sceneFrom: SceneProvider(initialIndex: 0))
            SpriteKitContainer(sceneFrom: SceneProvider(initialIndex: 1))
        }
    }
}


extension SKView {
    var hasSize: Bool {get{
        let sz = self.frame.size
        return !sz.width.isZero && !sz.height.isZero
    }}
}
