//
// Created by Andrew Dent on 25/5/18.
// Copyright (c) 2018 Touchgram Pty Ltd. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func notCloseTo(_ rhs:CGPoint) -> Bool {
        let epsilon : CGFloat = 2.0
        return abs(x - rhs.x) > epsilon || abs(y - rhs.y) > epsilon
    }
}