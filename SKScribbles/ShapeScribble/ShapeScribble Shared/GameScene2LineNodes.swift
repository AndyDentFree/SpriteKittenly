//
//  GameScene2LineNodes.swift
//  ShapeScribble Shared
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import SpriteKit

class GameScene2LineNodes: SKScene {

    var _pointsDrawn = [CGPoint]()
    var _tempNodes = [SKShapeNode]()
    var _colorsVary = false
    // see https://medium.com/@cgoldsby/swift-the-never-ending-rainbow-7e2471d9ac3
    var _colorIter:AnyIterator<SKColor> = SKColor.rainbowIterator(frequency: 0.1, phase1: 0.0, phase2: 2.0, phase3: 1.0, amplitude: 128.0, center: 128.0, repeat: true)

    class func newGameScene(colorsVaryingPerStroke:Bool) -> GameScene2LineNodes {
        var ret = GameScene2LineNodes(size: CGSize(width: 1366, height: 1024))
        // Set the scale mode to scale to fit the window
        ret.scaleMode = .aspectFill
        ret._colorsVary = colorsVaryingPerStroke
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
        if !pos.notCloseTo(_pointsDrawn.last!) {
            _pointsDrawn.append(pos) // instead of updatePath(pos)
        }
        removeChildren(in: _tempNodes) // neaten things up - this has no perceivable performance impact

        var finishedPts = SKShapeNode(splinePoints: &_pointsDrawn, count: _pointsDrawn.count)
        finishedPts.lineWidth = 1
        let drawColor = _colorsVary ? (_colorIter.next() ??  SKColor.blue) : SKColor.green
        finishedPts.strokeColor = drawColor
        finishedPts.glowWidth = 2.0
        addChild(finishedPts)
    }

    func updatePath(_ pos: CGPoint) {
        _pointsDrawn.append(pos)
        // add new node of two points
        var linesNode = SKShapeNode(points: &_pointsDrawn[_pointsDrawn.count - 2], count: 2)
        linesNode.lineWidth = 1
        linesNode.strokeColor = SKColor.yellow
        addChild(linesNode)
        _tempNodes.append(linesNode)  // WHOA! this makes a playground slow down massively
    }

#if os(watchOS)
    override func sceneDidLoad() {
    }
#else
    override func didMove(to view: SKView) {
    }
#endif

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene2LineNodes {

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
extension GameScene2LineNodes {

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

