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

    lazy var gpsLines: [Line] = { self.collectionPolygons.flatMap { $0 } }()

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

    var collectionPolygons: [Polygon] {
        self.stateData
            .filter { self.stateCollection.includes(stateName: $0.properties.NAME) }
            .map { $0.geometry.coordinates }
            .map { $0.continuous(resolution: self.hexGrid.size) }
            .map { $0.nudged(hexGrid: self.hexGrid) }
            .map { $0.continuous(resolution: self.hexGrid.size) }
            .map { $0.nudged(hexGrid: self.hexGrid) }
            .map { $0.continuous(resolution: self.hexGrid.size) }
            .map { $0.nudged(hexGrid: self.hexGrid) }
            .map { $0.simplifyNeighbors(hexGrid: self.hexGrid) }
            .flatMap { $0 }
    }

    var tiles: [HexGrid.Cell] { self.stateTiles.flatMap { $0 } }
    var hexPaths: [CGPath] {
        self.stateTiles.map { tiles in
            let p = CGMutablePath()
            let paths = tiles.compactMap { self.hexGrid.corners(for: $0).map(\.point).toCGPath }
            paths.forEach { p.addPath($0) }
            return p as CGPath
        }
        .filter(\.boundingBox.isDrawable)
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

    private var stateTiles: [[HexGrid.Cell]] {
        // A hex is a part of a state if the center is inside the state border path
        self.stateData
            .filter { self.stateCollection.includes(stateName: $0.properties.NAME) }
            .map { $0.geometry.coordinates }
            .map { $0.invertedLatitudes }
            .map { $0.cgPaths }
            .flatMap { $0 }
            .map { self.hexGrid.cells(intersecting: $0) }
    }

    private var stateGeometriesUrl: URL? {
        Bundle.main.url(forResource: "states", withExtension: "json")
    }

    var lineLengths: [Int] {
        self.collectionPolygons.flatMap({ $0 }).map(\.count)
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

    func continuous(resolution: CGFloat) -> [BorderData.Polygon] {
        self.map { $0.map { $0.continuous(resolution: resolution) } }
    }

    func nudged(hexGrid: HexGrid) -> [BorderData.Polygon] {
        self.map { $0.map { $0.nudged(hexGrid: hexGrid) } }
    }

    func dedupeNearestCorners(hexGrid: HexGrid) -> [BorderData.Polygon] {
        self.map { $0.map { $0.dedupeNearestCorners(hexGrid: hexGrid) } }
    }

    func simplifyNeighbors(hexGrid: HexGrid) -> [BorderData.Polygon] {
        self.map { $0.compactMap { $0.simplifyNeighbors(hexGrid: hexGrid) } }
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

    func continuous(resolution: CGFloat) -> [CGPoint] {
        var out: [CGPoint] = []

        self.first.map { out.append($0) }

        for idx in 0..<self.count - 1 {
            let last = self[idx]
            let next = self[idx + 1]
            let dist = last.distance(to: next)

            if resolution < dist {
                let segments = Int(ceil(dist / resolution))
                let interpolated = last.interpolated(to: next, segments: segments)
                out.append(contentsOf: interpolated)
            }

            out.append(next)
        }

        return out
    }

    func nudged(hexGrid: HexGrid) -> [CGPoint] {
        var out: [CGPoint] = []
        for point in self {
            // move halfway to the nearest corner
            let corner = hexGrid.corner(near: point)

            let midpoint = point.midpoint(to: corner.point)
            out.append(midpoint)
        }

        return out
    }

    func dedupeNearestCorners(hexGrid: HexGrid) -> [CGPoint] {
        var nearestCorners = [HexGrid.Corner: (offset: Int, element: CGPoint)]()

        for point in self.enumerated() {
            let corner = hexGrid.corner(near: point.element)

            guard let last = nearestCorners[corner] else {
                nearestCorners[corner] = point
                continue
            }

            if point.element.distance(to: corner.point) < last.element.distance(to: corner.point) {
                nearestCorners[corner] = point
            }
        }

        return nearestCorners.values.sorted(by: { $0.offset < $1.offset }).map(\.element)
    }

    func simplifyNeighbors(hexGrid: HexGrid) -> [CGPoint]? {
        guard let first = self.first else { return nil }

        var last = hexGrid.corner(near: first)
        var cornerPath: [HexGrid.Corner] = []

        cornerPath.append(last)

        for point in self {
            // add the *nearest* neighbor of last to the list and make it "last"
            let next = hexGrid.neighbors(of: last)
                .min(by: { $0.point.distance(to: point) < $1.point.distance(to: point) })!

            cornerPath.append(next)
            last = next
        }

        let outPoints = cornerPath
            .simplified
            .simplified
            .simplified
            .map(\.point)

        // 5 or fewer points can't make a closed hexagon
        return outPoints.count > 5 ? outPoints : nil
    }
}

extension Array where Element == HexGrid.Corner {
    var simplified: Self {
        guard self.count > 2 else { return [] }

        // finally trim all loose "leaves"
        var trimmed: [HexGrid.Corner] = []

        self.first.map { trimmed.append($0) }

        for idx in 1..<self.count - 1 {
            let last = self[idx - 1]
            let point = self[idx]
            let next = self[idx + 1]

            // If we have two _distinct_ neighbors, then it's safe to keep
            if last != next {
                trimmed.append(point)
            }
        }

        self.last.map { trimmed.append($0) }

        var deduped: [HexGrid.Corner] = []

        trimmed.first.map { deduped.append($0) }

        for idx in 1..<trimmed.count {
            let last = trimmed[idx - 1]
            let point = trimmed[idx]

            // If we have two _distinct_ neighbors, then it's safe to keep
            if last != point {
                deduped.append(point)
            }
        }

        return deduped
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
