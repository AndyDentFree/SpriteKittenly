//
//  RecordableScene.swift
//  VidExies
//
//  Created by Andrew Dent on 11/6/2025.
//


import SpriteKit

// saves time so we can read it when detach scene and feed it into an SKRenderer
class RecordableScene: SKScene {
    let id = UUID()  // for debugging only to detect different versions being created
    private(set) var lastFrameTime: TimeInterval = 0
    private var isPlaying: Bool = true
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        print("Scene \(id) presented on SKView")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if view == nil {
            if isPlaying {
                isPlaying = false  // transition to recording detected
                print("Scene \(id) stopped playing at \(lastFrameTime)")
            }
        } else {  // is playing, not rendering to a movie
            if !isPlaying {
                isPlaying = true  // transition to playing detected
                print("Scene \(id) started playing after recording")
            }
            lastFrameTime = currentTime
        }
        super.update(currentTime)
    }
}
