//
//  GameSceneParticleCrayon.swift
//  ShapeScribble Shared
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import SpriteKit

class GameSceneParticleCrayon: SKScene {

    lazy var _colorProvider: AnyIterator<SKColor> = AnyIterator { return SKColor.blue }
    var _emitter:SKEmitterNode? = nil
    var _lastPointDrawn = CGPoint()
    var _firstMove = false
    var _specifiedBirthRate: CGFloat = 0.0  // save from the crayon.sks file on touchDown

    class func newGameScene(strokeColors:AnyIterator<SKColor>) -> GameSceneParticleCrayon {
        return GameSceneParticleCrayon(size: CGSize(width: 1366, height: 1024), strokeColors:strokeColors)
    }

    convenience init (size:CGSize, strokeColors:AnyIterator<SKColor>) {
        self.init(size:size)
        _colorProvider = strokeColors
        scaleMode = .aspectFill
        // pale to show dark crayon
        self.backgroundColor = SKColor(red: 246/255.0, green: 241/255.0, blue: 223/255.0, alpha: 1.0)
    }
    
    func touchDown(atPoint pos: CGPoint) {
        guard let em = SKEmitterNode(fileNamed:"Crayon.sks") else {return}
        _lastPointDrawn = pos
        _emitter = em
        em.position = pos
        _specifiedBirthRate = em.particleBirthRate  // save to set in touchMoved
        em.particleBirthRate = 0  // don't start drawing until move a smidge so don't start with black blob
        addChild(em)
        em.targetNode = self // GOTCHA! - many getting started pages miss this! Just adding the node gives you a draggable node but not its output
        _firstMove = true  // flag to change touchMoved behaviour
    }

    func touchMoved(toPoint pos: CGPoint) {
        if _firstMove {
            guard pos.notCloseTo(_lastPointDrawn) else { return }  // don't start drawing until move a tiny bit
            _firstMove = false
            _emitter?.particleBirthRate = _specifiedBirthRate
        }
        updatePath(pos)
    }

    func touchUp(atPoint pos: CGPoint) {
        _emitter?.particleBirthRate = 0  // stop emitting before any other computation
        updatePath(pos)
    }

    func updatePath(_ pos: CGPoint) {
        guard pos.notCloseTo(_lastPointDrawn) else { return }
        _lastPointDrawn = pos
        _emitter?.position = pos
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
extension GameSceneParticleCrayon {

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
extension GameSceneParticleCrayon {

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

