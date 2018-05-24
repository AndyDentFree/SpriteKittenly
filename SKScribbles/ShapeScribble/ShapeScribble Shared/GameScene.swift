//
//  GameScene.swift
//  ShapeScribble Shared
//
//  Created by Andrew Dent on 23/5/18.
//  Copyright © 2018 Touchgram Pty Ltd. All rights reserved.
//

import SpriteKit

extension CGPoint {
  func notCloseTo(_ rhs:CGPoint) -> Bool {
    let epsilon : CGFloat = 4.0
    return abs(x - rhs.x) > epsilon || abs(y - rhs.y) > epsilon
  }
}

class GameScene: SKScene {

  private var pointsDrawn = [CGPoint]()
  private var tempNodes = [SKShapeNode]()
  private var drawModeIndex = 0
  
  class func newGameScene() -> GameScene {
      // Load 'GameScene.sks' as an SKScene.
      guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
          print("Failed to load GameScene.sks")
          abort()
      }
    
      // Set the scale mode to scale to fit the window
      scene.scaleMode = .aspectFill
      return scene
  }

  func clear()
  {
    removeAllChildren()
    pointsDrawn = [CGPoint]()
    tempNodes = [SKShapeNode]()
  }
  
  func setDrawMode(_ modeIndex:Int) {
    clear()
  }
  
  func touchDown(atPoint pos : CGPoint) {
    pointsDrawn = [pos]
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    guard pos.notCloseTo(pointsDrawn.last!) else { return }
    updatePath(pos)
  }
  
  func touchUp(atPoint pos : CGPoint) {
    if !pos.notCloseTo(pointsDrawn.last!){
      pointsDrawn.append(pos) // instead of updatePath(pos)
    }
    removeChildren(in: tempNodes) // neaten things up - this has no perceivable performance impact
    
    var finishedPts = SKShapeNode(splinePoints:&pointsDrawn, count:pointsDrawn.count)
    finishedPts.lineWidth = 1
    finishedPts.strokeColor = SKColor.green
    finishedPts.glowWidth = 2.0
    addChild(finishedPts)
  }
  
  func updatePath(_ pos : CGPoint) {
    pointsDrawn.append(pos)
    // add new node of two points
    var linesNode = SKShapeNode(points:&pointsDrawn[pointsDrawn.count-2], count:2)
    linesNode.lineWidth = 1
    linesNode.strokeColor = SKColor.yellow
    addChild(linesNode)
    tempNodes.append(linesNode)  // WHOA! this makes a playground slow down massively
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
extension GameScene {

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
extension GameScene {

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

