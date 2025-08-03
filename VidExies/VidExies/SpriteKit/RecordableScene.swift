//
//  RecordableScene.swift
//  VidExies
//
//  Created by Andy Dent on 11/6/2025.
//


import SpriteKit

// saves time so we can read it when detach scene and feed it into an SKRenderer
class RecordableScene: SKScene {
    let id = UUID()  // for debugging only to detect different versions being created
    private(set) var lastFrameTime: TimeInterval = 0
    private var isPlayingOnSKView: Bool = true
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        print("Scene \(id) presented on SKView")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if view == nil {
            if isPlayingOnSKView {
                isPlayingOnSKView = false  // transition to recording detected
                lastFrameTime = currentTime  // final update so recording starts after stopped on view
                print("Scene \(id) stopped playing at on view \(lastFrameTime)")
            }
        } else {  // is playing, not rendering to a movie
            if !isPlayingOnSKView {
                isPlayingOnSKView = true  // transition to playing detected
                print("Scene \(id) started playing on view after recording")
            }
            lastFrameTime = currentTime
        }
        super.update(currentTime)
    }
    
    // In your SKSceneDelegate or wherever you have access to the scene:

    func dumpChildren() {
        enumerateChildNodes(withName: "//*") { node, _ in
            let nodeType = type(of: node)
            let nameStr  = node.name ?? "<unnamed>"
            let pos      = node.position
            // Only some subclasses have .size – adjust as needed:
            let sizeStr: String
            if let sprite = node as? SKSpriteNode {
                sizeStr = "\(sprite.size)"
            } else if let shape = node as? SKShapeNode {
                sizeStr = "\(shape.frame.size)"
            } else if let em = node as? SKEmitterNode {
                sizeStr = "particleSize \(em.particleSize), emitterSize \(em.frame.size), birthRate \(em.particleBirthRate), positionRange \(em.particlePositionRange)"
            } else {
                sizeStr = "–"
            }
            print("[\(nodeType)] “\(nameStr)” at \(pos), size: \(sizeStr)")
        }
    }

}
