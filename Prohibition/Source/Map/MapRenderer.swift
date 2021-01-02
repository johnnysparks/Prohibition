//
//  MapData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/23/20.
//

import CoreGraphics
import Foundation

struct MapElement: Identifiable {
    enum ElementType {
        case city
        case border
    }

    let id = UUID()
    let type: ElementType
    let points: [CGPoint]
    let text: String

    func element(inContext ctx: MapDrawContext) -> MapElement {
        .init(
            type: self.type,
            points: self.points.map {
                CGPoint(x: $0.x - ctx.min.x, y: $0.y - ctx.min.y).applying(ctx.transform)
            },
            text: self.text
        )
    }
}

class MapRenderer {
    /// The targeted center of the viewport
    var center: CGPoint?
    /// The the size of the  viewport the map should be rendered in
    let screenSize: CGSize
    let hexGrid: HexGrid
    /// Underlying border data
    let borderData: BorderData
    /// Underlying city data
    let citiesData: [City]
    /// All the data to be drawn on the map
    var gpsElements: [MapElement] { self.borderElements + self.cityElements }

    var borders: [MapElement] {
        self.borderElements
            .map { $0.element(inContext: self.ctx) }
    }

    var debugBorders: [MapElement] {
        self.borderData.gpsLines
            .map { MapElement(type: .border, points: $0, text: "") }
            .map { $0.element(inContext: self.ctx) }
    }

    var cities: [MapElement] { self.cityElements.map { $0.element(inContext: self.ctx) } }

    private var borderElements: [MapElement] {
        self.borderData.gpsLines.map { MapElement(type: .border, points: $0, text: "") }
    }

    private var cityElements: [MapElement] {
        self.citiesData.map {
            MapElement(
                type: .city,
                points: self.hexGrid.corners(for: self.hexGrid.cell(from: $0.gps)).map(\.point),
                text: $0.name)
        }
    }

    lazy var ctx = MapDrawContext(renderer: self)

    init(screenSize: CGSize, hexGrid: HexGrid, border: BorderData, cities: [City]) {
        self.screenSize = screenSize
        self.hexGrid = hexGrid
        self.borderData = border
        self.citiesData = cities
    }
}

struct MapDrawContext {
    let min: CGPoint
    let scale: CGFloat
    let transform: CGAffineTransform

    init(renderer: MapRenderer) {
        let allPoints = renderer.gpsElements.flatMap { $0.points }

        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -1 * CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -1 * CGFloat.greatestFiniteMagnitude

        for point in allPoints {
            minX = Swift.min(minX, point.x)
            maxX = Swift.max(maxX, point.x)
            minY = Swift.min(minY, point.y)
            maxY = Swift.max(maxY, point.y)
        }

        let size = CGSize(width: maxX - minX, height: maxY - minY)
        let scaleY = renderer.screenSize.height / size.height
        let minScale = Swift.min(scaleY, renderer.screenSize.width / size.width)
        let translationY = renderer.screenSize.height * (minScale / scaleY)

        self.min = CGPoint(x: minX, y: minY)
        self.scale = minScale
        self.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: translationY)
            .scaledBy(x: 1, y: -1)
            .scaledBy(x: minScale, y: minScale)
    }
}
