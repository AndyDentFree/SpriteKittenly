//
//  CGPoint_GeometryExtensions.swift
//  ThrobsAndBobs
//
//  Created by AndyDent on 29/1/21.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func close(to rhs: CGPoint, radius: CGFloat) -> Bool {
        let deltaY = self.y - rhs.y
        let deltaX = self.x - rhs.x
        let distSquared = deltaX*deltaX + deltaY*deltaY
        return distSquared < (radius*radius)
    }
}
