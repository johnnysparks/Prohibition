//
//  MapApp.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/22/20.
//

import Foundation
import SwiftUI

protocol HexMappable: Identifiable, Hashable, CustomStringConvertible {
    var grid: HexGrid { get }
    var path: CGPath { get }
    var focus: HexGrid.Cell { get }
}

struct HexMappableState: HexMappable {
    var id: String { self.description }

    let grid: HexGrid
    let cells: Set<HexGrid.Cell>
    let focus: HexGrid.Cell
    let description: String
    var path: CGPath
}

struct PathMapView: View {
    @State var focus: HexGrid.Cell = HexGrid.Cell(q: -729, r: 617) // Cell(q: -555, r: 586)
    // Scale = number of hex tiles per screen wide
    @State var scale: CGFloat = 30

    let hexGrid = HexGrid(size: 0.157586, orientation: .pointy)
    var mappables: [HexMappableState]

    init() {
        self.mappables = BorderData(stateCollection: .continuous, hexGrid: self.hexGrid)
            .hexMappableStates
    }

    func offset(in size: CGSize) -> CGSize {
        let p = self.hexGrid.center(for: self.focus)
        return CGSize(width: size.width * 0.5 - p.x, height: size.height * 0.5 - p.y)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(self.mappables) { mappable in
                    HexMappableView(hex: mappable)
                }
                .offset(self.offset(in: geo.size))
                .scaleEffect(self.scale)
                .animation(.spring())
            }
            .background(Color.black)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ end in
                        let point = end.startLocation
                        // relative point to center to give us the desired translation from the current focus
                        let relative = CGPoint(x: point.x - geo.size.width * 0.5,
                                               y: point.y - geo.size.height * 0.5)
                            .applying(.init(scaleX: 1 / self.scale, y: 1 / self.scale))

                        let oldOffset = self.offset(in: geo.size).point
                        let newOffset = CGPoint(x: oldOffset.x - relative.x, y: oldOffset.y - relative.y)

                        let newFocus = CGPoint(x: geo.size.width * 0.5 - newOffset.x,
                                               y: geo.size.height * 0.5 - newOffset.y)

                        let focusCell = self.hexGrid.cell(from: newFocus)
                        let matches = self.mappables.filter { $0.cells.contains(focusCell) }
                        if !matches.isEmpty, let hitFocus = matches.first?.focus {
                            print(matches.map(\.description).joined(separator: " "))
                            self.focus = hitFocus
                        }
                    })
            )
        }
    }

    struct HexMappableView: View {
        let hex: HexMappableState
        let path: Path

        init(hex: HexMappableState) {
            self.hex = hex
            self.path = Path(hex.path)
        }

        var body: some View {
            self.path
                .fill(Color.green)
        }
    }
}

@main
struct MapApp: App {
    var body: some Scene {
        WindowGroup {
//            HexGridView()
//            MapView()
//            HexMapView()
            PathMapView()
        }
    }
}

extension CGRect {
    var midPoint: CGPoint { .init(x: self.midX, y: self.midY) }
}

extension CGSize {
    var point: CGPoint { .init(x: self.width, y: self.height) }
}

extension CGPoint {
    var size: CGSize { .init(width: self.x, height: self.y) }
}
