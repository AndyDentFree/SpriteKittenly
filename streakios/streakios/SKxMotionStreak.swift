//
//  SKxMotionStreak.swift
//  streakios
//
//  Created by Andrew Dent on 23/5/18.
//  based on the https://gist.github.com/hollance/8671187
// Motion streak code using SKShapeNode that didn't make it into the book iOS Games by Tutorials (raywenderlich.com)
// relies on extensions from https://github.com/raywenderlich/SKTUtils

import Foundation
import SpriteKit
import CoreGraphics

  private let MaxPoints = 100
  private let Thickness: CGFloat = 8.0
  private let CG_PI_2 = CGFloat(Double.pi/2)
  
class SKxMotionStreak : SKShapeNode {

    var _path: UIBezierPath
    var _points = [CGPoint](repeating:CGPoint(), count:MaxPoints)
    var _angles = [CGFloat](repeating: 0, count:MaxPoints)
    var _previousPoint = CGPoint()
    var _count: Int = 0
    var _index: Int = 0
    
    override init() {
        _path = UIBezierPath()
        super.init()
        self.lineWidth = 0.0
        self.fillColor = SKColorWithRGBA(255, g:255, b:255, a:64)
        self.isAntialiased = false
        // NOTE: This is necessary because of an issue with Sprite Kit.
        // If the ShapeNode does not cover the entire playing area when it
        // is created, then it gets hidden in the areas it doesn't cover,
        // even if you add those later. I consider this a bug. (Andy Note - 4yo assertion needs verifying)
      _path.move(to: CGPoint(x:0, y:0))
      _path.addLine(to: CGPoint(x:1000.0, y:1000.0))
      _path.close()
      self.path = _path.cgPath
    }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
    func addPosition(position: CGPoint) {
      // Ignore the new point if it is too close to the prevous point.
      if _previousPoint.distanceTo(position) < 2.0 {
        return
      }
      _points[_index] = position
      if _count < MaxPoints {
        _count += 1
      }
      let angle = (position - _previousPoint).angle
      _angles[_index] = angle + CG_PI_2
      _previousPoint = position
      _index += 1
      if _index == MaxPoints {
        _index = 0
      }
    }
    
    func updateStreak() {
      _path.removeAllPoints()
      if _count > 1 {
        let i = _index%_count
        var point = _points[i]
        var taper = CGFloat(1.0)/CGFloat(_count)
        var s: CGFloat = sin(_angles[i])*taper*Thickness
        var c: CGFloat = cos(_angles[i])*taper*Thickness
        _path.move(to: CGPoint(x:point.x+c, y:point.y+s))
        _path.addLine(to: CGPoint(x:point.x-c, y:point.y-s))
        for t in 1 ..< _count {
          let i = (_index+t)%_count
          point = _points[i]
          taper = CGFloat(t+1)/CGFloat(_count)
          s = sin(_angles[i])*taper*Thickness
          c = cos(_angles[i])*taper*Thickness
          _path.addLine(to: CGPoint(x:point.x-c, y:point.y-s))
        }
        for t in stride(from:(_count-1), to:1, by:-1) {
          let i = (_index+t)%_count
          point = _points[i]
          taper = CGFloat(t+1)/CGFloat(_count)
          s = sin(_angles[i])*taper*Thickness
          c = cos(_angles[i])*taper*Thickness
          _path.addLine(to: CGPoint(x:point.x+c, y:point.y+s))
        }
        _path.close()
        self.path = _path.cgPath
      }
    }
    
}

