//
//  HexGrid+Region.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import CoreGraphics
import Foundation

extension HexGrid {
    struct Region {
        let grid: HexGrid
        var focus: Cell
        let scale: CGFloat
        let screen: CGSize

        func cell(from tapPoint: CGPoint) -> Cell {
            let relative = CGPoint(x: tapPoint.x - self.screen.width * 0.5,
                                   y: tapPoint.y - self.screen.height * 0.5)
                .applying(.init(scaleX: 1 / self.scale, y: 1 / self.scale))

            // relative point to center to give us the desired translation from the current focus
            let oldOffset = self.offset.point
            let newOffset = CGPoint(x: oldOffset.x - relative.x, y: oldOffset.y - relative.y)
            let scaledScreen = self.screen.half.point.scaledUniformly(1 / self.scale).size
            let center = CGPoint(x: -newOffset.x + scaledScreen.width,
                                 y: -newOffset.y + scaledScreen.height)
            return self.grid.cell(from: center)
        }

        var offset: CGSize {
            let center = self.grid.center(for: self.focus)
            let scaled = self.screen.half.point.scaledUniformly(1 / self.scale).size
            return CGSize(width: -center.x + scaled.width, height: -center.y + scaled.height)
        }
    }
}
