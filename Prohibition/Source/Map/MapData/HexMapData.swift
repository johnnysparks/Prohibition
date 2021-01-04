//
//  HexMapData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import CoreGraphics
import Foundation

protocol HexMappable: Identifiable, Hashable, CustomStringConvertible {
    var grid: HexGrid { get }
    var path: CGPath { get }
    var focus: HexGrid.Cell { get }
}

struct HexGeometry: HexMappable {
    var id: String { self.description }

    let grid: HexGrid
    let cells: Set<HexGrid.Cell>
    let focus: HexGrid.Cell
    let description: String
    let path: CGPath
}

struct HexAnnotation {
    var id: String { self.label }
    let anchor: CGPoint
    let label: String
}

class HexMapData {
    private let grid: HexGrid
    let states: [HexGeometry]
    let cities: [HexGeometry]
    let annotations: [HexAnnotation]

    init(grid: HexGrid) {
        self.grid = grid
        self.states = StateMapData(collection: .continuous, hexGrid: grid).geometries
        self.cities = CityMapData(collection: .continuous, hexGrid: grid).geometries
        self.annotations = self.cities.map {
            let anchor = grid.center(for: $0.focus)
            return HexAnnotation(anchor: anchor, label: $0.description)
        }
    }
}
