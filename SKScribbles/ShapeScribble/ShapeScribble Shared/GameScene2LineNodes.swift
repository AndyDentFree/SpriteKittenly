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
    var _fillShape = false
    var _tempNodes = [SKShapeNode]()
    lazy var _colorProvider: AnyIterator<SKColor> = AnyIterator { return SKColor.blue }

    class func newGameScene(strokeColors:AnyIterator<SKColor>, fill:Bool=false) -> GameScene2LineNodes {
        return GameScene2LineNodes(size: CGSize(width: 1366, height: 1024), strokeColors:strokeColors, fill:fill)
    }

    convenience init (size:CGSize, strokeColors:AnyIterator<SKColor>, fill:Bool) {
        self.init(size:size)
        _colorProvider = strokeColors
        _fillShape = fill
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
        if !pos.notCloseTo(_pointsDrawn.last!) {
            _pointsDrawn.append(pos) // instead of updatePath(pos)
        }
        if _fillShape {
            _pointsDrawn.append(_pointsDrawn.first!)  // close it because we use the SKShapeNode(splinePoints...) init which can smooth the close
        }
        removeChildren(in: _tempNodes) // neaten things up - this has no perceivable performance impact

        var finishedPts = SKShapeNode(splinePoints: &_pointsDrawn, count: _pointsDrawn.count)
        finishedPts.lineWidth = 1
        if let drawColor = _colorProvider.next() {
            finishedPts.strokeColor = drawColor
            if _fillShape {
                finishedPts.fillColor = drawColor
            }
        }
        finishedPts.glowWidth = 4.0
        addChild(finishedPts)
    }

    func updatePath(_ pos: CGPoint) {
        _pointsDrawn.append(pos)
        // add new node of two points
        var linesNode = SKShapeNode(points: &_pointsDrawn[_pointsDrawn.count - 2], count: 2)
        linesNode.lineWidth = 1
        linesNode.strokeColor = SKColor.yellow
        if _fillShape {
            linesNode.fillColor = SKColor.yellow
        }
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

