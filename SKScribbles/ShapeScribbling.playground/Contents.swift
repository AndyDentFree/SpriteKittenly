//: This version generates a new SKShapeNode for each line moving slightly from the previous point
//: Is **very** sensitive to epsilon values, starting at 4 gets nearly real-time tracking without looking too jagged

import PlaygroundSupport
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
  
    override func didMove(to view: SKView) {

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
      // this has no perceivable performance impact removeChildren(in: tempNodes)
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
      tempNodes.append(linesNode)  // WHOA! this makes it slow down massively
    }
    
    override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
