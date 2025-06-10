//
//  RecordableScene.swift
//  VidExies
//
//  Created by Andrew Dent on 11/6/2025.
//


import SpriteKit

// saves time so we can read it when detach scene and feed it into an SKRenderer
class RecordableScene: SKScene {
    private(set) var lastFrameTime: TimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        lastFrameTime = currentTime
        super.update(currentTime)
    }
}
