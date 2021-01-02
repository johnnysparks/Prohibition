//
//  Cell.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/1/21.
//

import CoreGraphics
import Foundation

extension HexGrid {
    struct Cell: Hashable {
        let q: Int
        let r: Int

        init(q: Int, r: Int) {
            self.q = q
            self.r = r
        }

        init(q: CGFloat, r: CGFloat) {
            self.q = Int(round(q))
            self.r = Int(round(r))
        }
    }
}

extension HexGrid {
    func cell(from point: CGPoint) -> Cell {
        switch self.orientation {
        case .pointy:
            let qyc: CGFloat = -0.33333333
            let qxc: CGFloat = 0.577350269
            let ryc: CGFloat = 0.66666667
            return Cell(q: (qxc * point.x + qyc * point.y) / self.size,
                        r: (ryc * point.y) / self.size)

        case .flat:
            let qxc: CGFloat = 0.66666667
            let rxc: CGFloat = -0.33333333
            let ryc: CGFloat = 0.577350269
            return Cell(q: (qxc * point.x) / self.size,
                        r: (rxc * point.x + ryc * point.y) / self.size)
        }
    }

    func center(for cell: Cell) -> CGPoint {
        switch self.orientation {
        case .flat:
            let xqc: CGFloat = 1.5
            let yqc: CGFloat = 0.866025404
            let yrc: CGFloat = 1.73205081
            return CGPoint(x: self.size * (xqc * CGFloat(cell.q)),
                           y: self.size * (yqc * CGFloat(cell.q) + yrc * CGFloat(cell.r)))

        case .pointy:
            let xqc: CGFloat = 1.73205081
            let xrc: CGFloat = 0.866025404
            let yrc: CGFloat = 1.5

            return CGPoint(x: self.size * (xqc * CGFloat(cell.q) + xrc * CGFloat(cell.r)),
                           y: self.size * (yrc * CGFloat(cell.r)))
        }
    }
}
