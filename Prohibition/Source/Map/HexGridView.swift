//
//  HexGridView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import Foundation
import SwiftUI

struct HexGridView: View {
    let grid = HexGrid(size: 20, orientation: .flat)
    var body: some View {
        var borderPath = Path()

        var centersPath = Path()

        for q in 0..<20 {
            for r in 0..<20 {
                let cell = HexGrid.Cell(q: q, r: r)
                let corners = self.grid.corners(for: cell)

                borderPath.move(to: corners[5].point)

                for c in corners {
                    borderPath.addLine(to: c.point)
                }

                let center = self.grid.center(for: cell)

                centersPath.addEllipse(in: .init(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
            }
        }

        return ZStack {
            borderPath
                .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .foregroundColor(.green)

            centersPath
                .foregroundColor(.red)
        }
    }
}
