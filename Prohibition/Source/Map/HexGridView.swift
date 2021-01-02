//
//  HexGridView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import Foundation
import SwiftUI

struct HexGridView: View {
    @State var focus: HexGrid.Cell = HexGrid.Cell(q: 5, r: 5)
    @State var scale: CGFloat = 1

    let grid = HexGrid(size: 20, orientation: .flat)

    func offset(in size: CGSize) -> CGSize {
        let p = self.grid.center(for: self.focus)
        return CGSize(width: size.width * 0.5 - p.x, height: size.height * 0.5 - p.y)
    }

    var body: some View {
        let cells = (0..<10).map { q in
            (0..<10).map { r in
                HexGrid.Cell(q: q, r: r)
            }
        }.flatMap { $0 }

        return GeometryReader { geo in
            ZStack {
                ForEach(cells, id: \.self) { cell in
                    HexGridTile(grid: self.grid, cell: cell) { cell in
                        self.focus = cell
                    }
                }
            }
            .offset(self.offset(in: geo.size))
            .scaleEffect(self.scale)
            .animation(.spring())
        }
        .background(Color.black)
    }
}

struct HexGridTile: View {
    let grid: HexGrid
    let cell: HexGrid.Cell

    let onTap: (HexGrid.Cell) -> Void

    var body: some View {
        self.backgroundPath
            .fill(Color.blue)
            .opacity(0.3)
            .onTapGesture {
                self.onTap(self.cell)
            }

        self.centerPath
            .foregroundColor(.red)

        self.backgroundPath
            .stroke(lineWidth: 1)
            .foregroundColor(.black)
    }

    var centerPath: Path {
        let center = self.grid.center(for: self.cell)
        return Path(ellipseIn: .init(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
    }

    var backgroundPath: Path {
        var path = Path()
        let corners = self.grid.corners(for: self.cell)

        path.move(to: corners[5].point)

        for c in corners {
            path.addLine(to: c.point)
        }

        return path
    }
}
