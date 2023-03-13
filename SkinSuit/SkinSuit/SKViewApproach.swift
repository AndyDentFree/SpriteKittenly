//
//  SKViewApproach.swift
//  SkinSuit
//
//  Created by AndyDent on 27/1/2023.
//


import SpriteKit
import SwiftUI


// relies on scenes created and passed in already
struct SpriteKitContainer : AgnosticViewRepresentable {
    
    typealias RepresentedViewType = SKView

    
    @Binding var sceneIndex: Int
    let scenes: [SKScene]
    let transitions: [SKTransition]
    

    // memoizes state to be passed back in via updateUIView context
    class Coordinator: NSObject {
        var isFirstScene = true
        var currentSceneIndex = -1  // use to compare so don't try to do transitions to same scene
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeView(context: Context) -> SKView {
       return SKView(frame: .zero)
    }
 
    // triggered on first load and then re-triggered because dependency on @State sceneIndex which is altered by button
    func updateView(_ view: SKView, context: Context) {
        let index = $sceneIndex.wrappedValue
        if context.coordinator.isFirstScene {
            view.presentScene(scenes[index])
            context.coordinator.isFirstScene = false
            context.coordinator.currentSceneIndex =  index
        } else {  // use different presentScene that takes concrete SKTransition
            if context.coordinator.currentSceneIndex !=  index {
                context.coordinator.currentSceneIndex =  index
                view.presentScene(scenes[index], transition: transitions[index])
            }
        }
    }
    
    static func dismantleView(view: RepresentedViewType, coordinator: Self.Coordinator) {
        view.presentScene(nil)        
    }

}

struct SKViewApproach: View {
    // local state for sceneIndex so no interference testing each approach
    @State var sceneIndex = 0
    let scenes: [SKScene]
    let transitions: [SKTransition]
    
    var body: some View {
        VStack {
            SpriteKitContainer(sceneIndex: $sceneIndex, scenes: scenes, transitions: transitions)
            Button("Toggle Scene to \(2 - sceneIndex)") {
                sceneIndex = 1 - sceneIndex
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Text("Using wrapped SKView to change scene")
        }
        .padding()
    }
}


// so we can preview just the SKView
struct SKViewApproach_Previews: PreviewProvider {

    static var previews: some View {
        let scenes:[SKScene] = [SKScene(fileNamed: "Scene0")!,  SKScene(fileNamed: "Scene1")!].map{
            $0.scaleMode = .aspectFill
            return $0
        }
        let transitions = [
            SKTransition.push(with: .up, duration: 2.0),
            SKTransition.push(with: .down, duration: 1.0)]
        SKViewApproach(scenes: scenes, transitions: transitions)
    }
}

