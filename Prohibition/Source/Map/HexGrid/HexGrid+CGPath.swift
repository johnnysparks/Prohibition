//
//  HexGrid+CGPath.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/1/21.
//

import CoreGraphics
import Foundation

extension HexGrid {
    func hexified(path: CGPath) -> CGPath? {
        self.path(for: self.cells(intersecting: path))
    }

    func cells(intersecting path: CGPath) -> [Cell] {
        var cells: [Cell] = []

        let cornerCells = [
            CGPoint(x: path.boundingBox.minX, y: path.boundingBox.minY),
            CGPoint(x: path.boundingBox.maxX, y: path.boundingBox.minY),
            CGPoint(x: path.boundingBox.minX, y: path.boundingBox.maxY),
            CGPoint(x: path.boundingBox.maxX, y: path.boundingBox.maxY),
        ].map { self.cell(from: $0) }

        let minQ = cornerCells.map(\.q).min()!
        let maxQ = cornerCells.map(\.q).max()!
        let minR = cornerCells.map(\.r).min()!
        let maxR = cornerCells.map(\.r).max()!

        for q in minQ...maxQ {
            for r in minR...maxR {
                let cell = HexGrid.Cell(q: q, r: r)
                let center = self.center(for: cell)

                if path.contains(center, using: .evenOdd) {
                    cells.append(cell)
                }
            }
        }

        return cells
    }

    func path(for cells: [Cell]) -> CGPath? {
        guard !cells.isEmpty else { return nil }
        let p = CGMutablePath()
        let paths = cells.compactMap { self.corners(for: $0).map(\.point).toCGPath }
        paths.forEach { p.addPath($0) }
        return p as CGPath
    }
}
