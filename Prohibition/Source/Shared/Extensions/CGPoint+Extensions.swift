//
//  CGPoint+Extensions.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/31/20.
//

import CoreGraphics

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let x = self.x - other.x
        let y = self.y - other.y

        return sqrt(x * x) + sqrt(y * y)
    }

    func midpoint(to other: CGPoint) -> CGPoint {
        let minX = min(self.x, other.x)
        let maxX = max(self.x, other.x)
        let minY = min(self.y, other.y)
        let maxY = max(self.y, other.y)
        let dx = maxX - minX
        let dy = maxY - minY

        return .init(x: 0.5 * dx + minX, y: 0.5 * dy + minY)
    }

    func interpolated(to other: CGPoint, segments: Int) -> [CGPoint] {
        guard segments > 0 else { return [] }

        // `self` is the starting point, as we append points to the line,
        // we always needs to remember to retain order so that lines don't criss-cross on the map
        let xMin = min(self.x, other.x)
        let yMin = min(self.y, other.y)
        let yDist = max(self.y, other.y) - yMin
        let xDist = max(self.x, other.x) - xMin
        let yIncrement = yDist / CGFloat(segments)
        let xIncrement = xDist / CGFloat(segments)

        var xs = (1..<segments).map { xMin + xIncrement * CGFloat($0) }
        var ys = (1..<segments).map { yMin + yIncrement * CGFloat($0) }

        if self.y > other.y {
            ys.reverse()
        }

        if self.x > other.x {
            xs.reverse()
        }

        guard xIncrement != 0 else { // Can't divide 0 into segments
            return ys.map { CGPoint(x: self.x, y: $0) }
        }

        guard yIncrement != 0 else { // Can't divide 0 into segments
            return xs.map { CGPoint(x: $0, y: self.y) }
        }

        return zip(xs, ys).map(CGPoint.init)
    }
}
