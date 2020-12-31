//
//  HexGrid.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import CoreGraphics

struct HexGrid {
    let size: CGFloat
    let orientation: Orientation

    enum Orientation {
        case pointy
        case flat
    }

    struct Corner: Hashable {
        enum MainArm: Int {
            case n, s, e, w
        }

        let arm: MainArm
        let point: CGPoint

        func neighbors(for size: CGFloat) -> [Corner] {
            //swiftlint:disable comma
            let shortSize = 0.866025404 * size
            let halfSize = 0.5 * size

            switch self.arm {
            case .n:
                return [
                    Corner(arm: .s, point: .init(x: self.point.x,             y: self.point.y - size)),
                    Corner(arm: .s, point: .init(x: self.point.x - shortSize, y: self.point.y + halfSize)),
                    Corner(arm: .s, point: .init(x: self.point.x + shortSize, y: self.point.y + halfSize)),
                ]
            case .s:
                return [
                    Corner(arm: .n, point: .init(x: self.point.x,             y: self.point.y + size)),
                    Corner(arm: .n, point: .init(x: self.point.x + shortSize, y: self.point.y - halfSize)),
                    Corner(arm: .n, point: .init(x: self.point.x - shortSize, y: self.point.y - halfSize)),
                ]
            case .e:
                return [
                    Corner(arm: .w, point: .init(x: self.point.x + size,     y: self.point.y)),
                    Corner(arm: .w, point: .init(x: self.point.x + halfSize, y: self.point.y - shortSize)),
                    Corner(arm: .w, point: .init(x: self.point.x + halfSize, y: self.point.y + shortSize)),
                ]
            case .w:
                return [
                    Corner(arm: .e, point: .init(x: self.point.x - size,     y: self.point.y)),
                    Corner(arm: .e, point: .init(x: self.point.x - halfSize, y: self.point.y + shortSize)),
                    Corner(arm: .e, point: .init(x: self.point.x - halfSize, y: self.point.y - shortSize)),
                ]
            }
        }
    }

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

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

extension HexGrid {
    func corner(near point: CGPoint) -> Corner? {
        self.corners(for: self.cell(from: point))
            .min(by: { $0.point.distance(to: point) < $1.point.distance(to: point) })
    }
}

extension HexGrid.Corner {
    func distance(to other: HexGrid.Corner) -> CGFloat {
        self.point.distance(to: other.point)
    }
}
