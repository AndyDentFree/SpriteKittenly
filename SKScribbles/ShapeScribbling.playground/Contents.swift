//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

class GameScene: SKScene {
    
    private var linesNode : SKShapeNode? = nil
    private var pointsDrawn = [CGPoint]()
  
    override func didMove(to view: SKView) {

    }
    
    func touchDown(atPoint pos : CGPoint) {
        pointsDrawn = [pos]
    }
    
    func touchMoved(toPoint pos : CGPoint) {
      guard pos != pointsDrawn.last else { return }
      pointsDrawn.append(pos)
      updatePath()
    }
    
    func touchUp(atPoint pos : CGPoint) {
      guard pos != pointsDrawn.last else { return }
      pointsDrawn.append(pos)
      updatePath()
    }
  
    func updatePath() {
      
      // start with completely re-creating the node. Horribly slow
      if linesNode != nil {
        removeChildren(in: [linesNode!])
      }
      linesNode = SKShapeNode(points:&pointsDrawn, count:pointsDrawn.count)
      linesNode!.lineWidth = 1
      linesNode!.strokeColor = SKColor.green
      addChild(linesNode!)
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
