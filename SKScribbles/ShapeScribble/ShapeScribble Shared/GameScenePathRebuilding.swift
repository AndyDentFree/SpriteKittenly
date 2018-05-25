//
//  GameScenePathRebuilding.swift
//  ShapeScribble Shared
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//
import Foundation
import SpriteKit
import CoreGraphics

// pulls ideas from the streakios sample SKxMotionStreak
class GameScenePathRebuilding: SKScene {

    private var _pointsDrawn = [CGPoint]()
    var _path = CGMutablePath()
    var _bigNode = SKShapeNode()

    class func newGameScene() -> GameScenePathRebuilding {
        var ret = GameScenePathRebuilding(size: CGSize(width: 1366, height: 1024))
        // Set the scale mode to scale to fit the window
        ret.scaleMode = .aspectFill
        return ret
    }

    func touchDown(atPoint pos: CGPoint) {
        _pointsDrawn = [pos]
    }

    func touchMoved(toPoint pos: CGPoint) {
        guard pos.notCloseTo(_pointsDrawn.last!) else {
            return
        }
        updatePath(pos)
    }

    func touchUp(atPoint pos: CGPoint) {
        guard pos.notCloseTo(_pointsDrawn.last!) else {
            return
        }
        updatePath(pos)
    }

    func updatePath(_ pos: CGPoint) {
        // not called unless moved at least a few pixels from initial touch
        _pointsDrawn.append(pos)
        _path = CGMutablePath()
        //_path.removeAllPoints()
        _path.move(to:_pointsDrawn[0])
        for pt in _pointsDrawn[1...] {
            _path.addLine(to:pt)
        }
        //_path.close()
        _bigNode.lineWidth = 2.0
        _bigNode.strokeColor = SKColor.green
        _bigNode.path = _path
    }

#if os(watchOS)
    override func sceneDidLoad() {
        setupOnLoad()
    }
#else
    override func didMove(to view: SKView) {
        setupOnLoad()
    }
#endif

    func setupOnLoad() {
        _bigNode.lineWidth = 0.0
        //_bigNode.fillColor = SKColor(red:1.0, green:1.0, blue:1.0, alpha:0.25)
        _bigNode.isAntialiased = false
        // NOTE: This is necessary because of an issue with Sprite Kit.
        // If the ShapeNode does not cover the entire playing area when it
        // is created, then it gets hidden in the areas it doesn't cover,
        // even if you add those later. I consider this a bug. (Andy Note - 4yo assertion needs verifying)
        _path.move(to: CGPoint(x:0, y:0))
        _path.addLine(to: CGPoint(x:1000.0, y:1000.0))
        //_path.close()
        _bigNode.path = _path
        addChild(_bigNode)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScenePathRebuilding {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }


}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScenePathRebuilding {

    override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }

}
#endif

