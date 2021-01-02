//
//  Corner.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/1/21.
//

import CoreGraphics
import Foundation

extension HexGrid {
    struct Corner: Hashable {
        enum MainArm: Int {
            case n, s, e, w
        }

        let arm: MainArm
        let point: CGPoint
    }
}

extension HexGrid {
    func neighbors(of corner: Corner) -> [Corner] {
        //swiftlint:disable comma
        let shortSize = 0.866025404 * self.size
        let halfSize = 0.5 * self.size
        let point = corner.point

        switch corner.arm {
        case .n:
            return [
                Corner(arm: .s, point: .init(x: point.x,             y: point.y - self.size)),
                Corner(arm: .s, point: .init(x: point.x - shortSize, y: point.y + halfSize)),
                Corner(arm: .s, point: .init(x: point.x + shortSize, y: point.y + halfSize)),
            ]
        case .s:
            return [
                Corner(arm: .n, point: .init(x: point.x,             y: point.y + self.size)),
                Corner(arm: .n, point: .init(x: point.x + shortSize, y: point.y - halfSize)),
                Corner(arm: .n, point: .init(x: point.x - shortSize, y: point.y - halfSize)),
            ]
        case .e:
            return [
                Corner(arm: .w, point: .init(x: point.x + self.size, y: point.y)),
                Corner(arm: .w, point: .init(x: point.x + halfSize,  y: point.y - shortSize)),
                Corner(arm: .w, point: .init(x: point.x + halfSize,  y: point.y + shortSize)),
            ]
        case .w:
            return [
                Corner(arm: .e, point: .init(x: point.x - self.size, y: point.y)),
                Corner(arm: .e, point: .init(x: point.x - halfSize,  y: point.y + shortSize)),
                Corner(arm: .e, point: .init(x: point.x - halfSize,  y: point.y - shortSize)),
            ]
        }
    }

    func corners(for cell: Cell) -> [Corner] {
        //swiftlint:disable comma
        let center = self.center(for: cell)
        let shortSize = 0.866025404 * self.size
        let halfSize = 0.5 * self.size

        switch self.orientation {
        case .flat:
            return [
                // NE
                Corner(arm: .w, point: .init(x: center.x + halfSize,  y: center.y - shortSize)),
                // E
                Corner(arm: .e, point: .init(x: center.x + self.size, y: center.y)),
                // SE
                Corner(arm: .w, point: .init(x: center.x + halfSize,  y: center.y + shortSize)),
                // SW
                Corner(arm: .e, point: .init(x: center.x - halfSize,  y: center.y + shortSize)),
                // W
                Corner(arm: .w, point: .init(x: center.x - self.size, y: center.y)),
                // NW
                Corner(arm: .e, point: .init(x: center.x - halfSize,  y: center.y - shortSize)),
            ]
        case .pointy:
            return [
                // N
                Corner(arm: .n, point: .init(x: center.x,             y: center.y - self.size)),
                // NE
                Corner(arm: .s, point: .init(x: center.x + shortSize, y: center.y - halfSize)),
                // SE
                Corner(arm: .n, point: .init(x: center.x + shortSize, y: center.y + halfSize)),
                // S
                Corner(arm: .s, point: .init(x: center.x,             y: center.y + self.size)),
                // SW
                Corner(arm: .n, point: .init(x: center.x - shortSize, y: center.y + halfSize)),
                // NW
                Corner(arm: .s, point: .init(x: center.x - shortSize, y: center.y - halfSize)),
            ]
        }
    }
}

extension HexGrid {
    func corner(near point: CGPoint) -> Corner {
        // Corners always returns 6 elements so we can safely force unwrap
        self.corners(for: self.cell(from: point))
            .min(by: { $0.point.distance(to: point) < $1.point.distance(to: point) })!
    }
}
