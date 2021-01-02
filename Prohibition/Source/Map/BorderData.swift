//
//  BorderData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/28/20.
//

import CoreGraphics
import Foundation

class BorderData {
    /// The collection of visible states
    let stateCollection: StateCollection
    /// The snapping and resolution of the borders
    let hexGrid: HexGrid

    init(stateCollection: StateCollection, hexGrid: HexGrid) {
        self.stateCollection = stateCollection
        self.hexGrid = hexGrid
    }

    var stateData: [States.StateFeature] {
        guard let url = self.stateGeometriesUrl else { return [] }

        let allStates: [States.StateFeature]
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONDecoder().decode(States.self, from: data)
            allStates = json.features
        } catch {
            print(error)
            allStates = []
        }

        return allStates
    }

    var hexMappableStates: [HexMappableState] {
        self.stateData
            .filter { self.stateCollection.includes(stateName: $0.properties.NAME) }
            .compactMap { state -> HexMappableState? in
                let myTiles = state.geometry
                    .coordinates
                    .invertedLatitudes
                    .cgPaths
                    .compactMap { self.hexGrid.cells(intersecting: $0) }
                    .flatMap { $0 }

                guard !myTiles.isEmpty else { return nil }

                let focusQ = Int(round(Double(myTiles.map(\.q).reduce(0, +)) / Double(myTiles.count)))
                let focusR = Int(round(Double(myTiles.map(\.r).reduce(0, +)) / Double(myTiles.count)))

                return HexMappableState(grid: self.hexGrid,
                                        cells: Set(myTiles),
                                        focus: HexGrid.Cell(q: focusQ, r: focusR),
                                        description: state.properties.NAME,
                                        path: self.hexGrid.path(for: myTiles)!)
            }
    }

    private var stateGeometriesUrl: URL? {
        Bundle.main.url(forResource: "states", withExtension: "json")
    }
}

// MARK: - Types

extension BorderData {
    typealias Line = [CGPoint]
    typealias Polygon = [Line]

    enum StateCollection {
        case continuous
        case california
        case jersey
        case rhodeIsland
        case westCoast
        case newYork
        case all
        case gulf
        case eastern
        case midwest

        func includes(stateName: String) -> Bool {
            switch self {
            case .continuous:
                return !["Alaska", "Hawaii", "Puerto Rico"].contains(stateName)
            case .all:
                return true
            case .jersey:
                return stateName == "New Jersey"
            case .california:
                return stateName == "California"
            case .newYork:
                return stateName == "New York"
            case .rhodeIsland:
                return stateName == "Rhode Island"
            case .westCoast:
                return ["Oregon", "Washington", "California"].contains(stateName)
            case .gulf:
                return ["Texas", "Florida", "Alabama", "Louisiana", "Mississippi"].contains(stateName)
            case .eastern:
                return ![
                    "Oregon", "Washington", "California", "Nevada", "Idaho", "Montana", "Colorado", "Wyoming",
                    "Utah", "Arizona", "New Mexico", "Texas", "North Dakota", "South Dakota", "Nebraska",
                    "Oklahoma", "Alaska", "Hawaii", "Kansas", "Puerto Rico",
                    "Maine", "Minnesota", "Massachusetts", "Vermont", "Rhode Island", "New Hampshire"
                ].contains(stateName)
            case .midwest:
                return ["Wisconsin", "Illinois", "Minnesota", "Iowa"].contains(stateName)
            }
        }
    }

    struct States: Codable {
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
}

// MARK: - Poly Reduction

extension Array where Element == BorderData.Polygon {
    var invertedLatitudes: [BorderData.Polygon] {
        self.map { $0.map(\.invertedLatitudes) }
    }

    var cgPaths: [CGPath] {
        self.map { $0.compactMap(\.toCGPath) }.flatMap { $0 }
    }
}

extension Array where Element == CGPoint {
    var invertedLatitudes: Self { self.map(\.invertedLatitude) }

    var toCGPath: CGPath? {
        guard let first = self.first else { return nil }
        let p = CGMutablePath()
        p.move(to: first)
        p.addLines(between: self)
        return p
    }
}

extension CGRect {
    var area: CGFloat { self.height * self.width }
    var isDrawable: Bool { self.area > 0 && self.area < 99999999 }
}

extension CGPoint {
    var invertedLatitude: CGPoint { .init(x: self.x, y: -self.y + 180) }
}

extension Array where Element == CGPath {
    var union: CGPath {
        let p = CGMutablePath()
        self.forEach { p.addPath($0) }
        return p as CGPath
    }
}
