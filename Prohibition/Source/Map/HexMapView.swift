//
//  HexMapView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/1/21.
//

import Foundation
import SwiftUI

struct HexMapView: View {
    @State var focus: HexGrid.Cell = HexGrid.Cell(q: -729, r: 617)
    // Scale = number of hex tiles per screen wide
    @State var scale: CGFloat = 20

    let hexGrid = HexGrid(size: 0.157586, orientation: .pointy)
    let tiles: [HexGrid.Cell]

    init() {
        self.tiles = BorderData(stateCollection: .continuous, hexGrid: self.hexGrid).tiles
    }

    func offset(in size: CGSize) -> CGSize {
        let p = self.hexGrid.center(for: self.focus)
        return CGSize(width: size.width * 0.5 - p.x, height: size.height * 0.5 - p.y)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(self.tiles, id: \.self) { tile in
                    TileView(hex: self.hexGrid, tile: tile) { tappedTile in
                        self.focus = tappedTile
                    }
                }
                .offset(self.offset(in: geo.size))
                .scaleEffect(self.scale)
                .animation(.spring())
            }
        }
        .background(Color.black)
    }

    struct TileView: View {
        let hex: HexGrid
        let tile: HexGrid.Cell
        let onTap: (HexGrid.Cell) -> Void
        let path: Path

        init(hex: HexGrid, tile: HexGrid.Cell, onTap: @escaping (HexGrid.Cell) -> Void) {
            self.hex = hex
            self.tile = tile
            self.onTap = onTap
            self.path = Path { p in
                let corners = hex.corners(for: tile)
                p.move(to: corners[0].point)
                p.addLines(corners.map(\.point))
            }
        }

        var body: some View {
            self.path
                .fill(Color.green)
                .opacity(0.3)
                .contentShape(self.path)
                .onTapGesture {
                    self.onTap(self.tile)
                }

            self.path
                .stroke(lineWidth: self.hex.size * 0.1)
                .foregroundColor(.black)
        }
    }
}
