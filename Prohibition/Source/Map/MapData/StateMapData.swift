//
//  StateMapData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import CoreGraphics
import Foundation

// MARK: - Types

private typealias Line = [CGPoint]
private typealias Polygon = [Line]

private struct SearializedBorders: Codable {
    let type: String
    let features: [StateFeature]

    struct StateFeature: Codable {
        struct Properties: Codable {
            let GEO_ID: String
            let STATE: String
            let NAME: String
            let LSAD: String
            let CENSUSAREA: Double
        }

        struct Geometry: Codable {
            enum CodingKeys: String, CodingKey {
                case type
                case coordinates
            }

            let type: String
            let coordinates: [Polygon]

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.type = try container.decode(String.self, forKey: .type)

                let points: [[[[CGFloat]]]]
                switch self.type {
                case "MultiPolygon":
                    points = try container.decode([[[[CGFloat]]]].self, forKey: .coordinates)
                case "Polygon":
                    points = [try container.decode([[[CGFloat]]].self, forKey: .coordinates)]
                default:
                    points = []
                }

                self.coordinates = points.map { $0.map { $0.map { CGPoint(x: $0[0], y: $0[1]) } } }
            }
        }

        let type: String
        let properties: Properties
        let geometry: Geometry
    }
}

class StateMapData {
    /// The collection of visible states
    let collection: StateCollection
    /// The snapping and resolution of the borders
    let hexGrid: HexGrid

    init(collection: StateCollection, hexGrid: HexGrid) {
        self.collection = collection
        self.hexGrid = hexGrid
    }

    var geometries: [HexGeometry] {
        self.stateData
            .filter { self.collection.includes(stateName: $0.properties.NAME) }
            .compactMap { state -> HexGeometry? in
                let myTiles = state.geometry
                    .coordinates
                    .invertedLatitudes
                    .scaledUniformly(100)
                    .cgPaths
                    .compactMap { self.hexGrid.cells(intersecting: $0) }
                    .flatMap { $0 }

                guard !myTiles.isEmpty else { return nil }

                let focusQ = Int(round(Double(myTiles.map(\.q).reduce(0, +)) / Double(myTiles.count)))
                let focusR = Int(round(Double(myTiles.map(\.r).reduce(0, +)) / Double(myTiles.count)))

                return .init(
                    grid: self.hexGrid,
                    cells: Set(myTiles),
                    focus: HexGrid.Cell(q: focusQ, r: focusR),
                    description: state.properties.NAME,
                    path: self.hexGrid.path(for: myTiles)!
                )
            }
    }

    // MARK: - Private

    private var stateData: [SearializedBorders.StateFeature] {
        guard let url = self.stateGeometriesUrl else { return [] }

        let allStates: [SearializedBorders.StateFeature]
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONDecoder().decode(SearializedBorders.self, from: data)
            allStates = json.features
        } catch {
            print(error)
            allStates = []
        }

        return allStates
    }

    private var stateGeometriesUrl: URL? {
        Bundle.main.url(forResource: "states", withExtension: "json")
    }
}

// MARK: - Poly Reduction

extension Array where Element == Polygon {
    func scaledUniformly(_ amount: CGFloat) -> [Polygon] {
        self.map { $0.map { $0.scaledUniformly(amount) } }
    }

    var invertedLatitudes: [Polygon] {
        self.map { $0.map(\.invertedLatitudes) }
    }

    var cgPaths: [CGPath] {
        self.map { $0.compactMap(\.toCGPath) }.flatMap { $0 }
    }
}
