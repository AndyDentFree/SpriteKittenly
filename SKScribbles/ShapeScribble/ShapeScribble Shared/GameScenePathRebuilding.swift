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
    lazy var _colorProvider: AnyIterator<SKColor> = AnyIterator { return SKColor.blue }

    class func newGameScene(strokeColors:AnyIterator<SKColor>) -> GameScenePathRebuilding {
        return GameScenePathRebuilding(size: CGSize(width: 1366, height: 1024), strokeColors:strokeColors)
        // Set the scale mode to scale to fit the window
    }

    convenience init (size:CGSize, strokeColors:AnyIterator<SKColor>) {
        self.init(size:size)
        _colorProvider = strokeColors
        scaleMode = .aspectFill
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
        // recreated path if you want to see only one, leave it there and move(to:) starts new sub-path
        // _path = CGMutablePath()
        _path.move(to:_pointsDrawn[0])
        for pt in _pointsDrawn[1...] {
            _path.addLine(to:pt)
        }
        //_path.close()
        _bigNode.lineWidth = 2.0
        if let drawColor = _colorProvider.next() {
            _bigNode.strokeColor = drawColor
        }
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

