//
//  HexGrid.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import CoreGraphics
import Foundation

struct HexGrid: Equatable, Hashable {
    enum Orientation {
        case pointy
        case flat
    }

    let size: CGFloat
    let orientation: Orientation
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

extension HexGrid.Corner {
    func distance(to other: HexGrid.Corner) -> CGFloat {
        self.point.distance(to: other.point)
    }
}
