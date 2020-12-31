//
//  LegacyMapData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/25/20.
//

import CoreGraphics
import Foundation

class LegacyMapData {
    let viewScale: CGSize

    init(scale: CGSize) {
        self.viewScale = scale
    }

    struct MapPoint: Equatable {
        let idx: Int
        let border: String
        let mileMark: Double
        let lat: Double
        let long: Double
        let state1: String
        let state2: String

        init?(array: [String]) {
            guard let idx = Int(array[0]),
                  let mileMark = Double(array[2]),
                  let lat = Double(array[3]),
                  let long = Double(array[4]) else {
                return nil
            }

            self.idx = idx
            self.border = array[1]
            self.mileMark = mileMark
            self.lat = lat
            self.long = long
            self.state1 = array[5]
            self.state2 = array[6]
        }

        func point(from origin: CGPoint, in scale: CGSize) -> CGPoint {
            CGPoint(x: self.long - Double(origin.x), y: self.lat - Double(origin.y))
                .applying(.init(scaleX: scale.width, y: scale.height))
        }
    }

    var scaledOrigin: CGPoint { CGPoint(x: self.min.x, y: self.min.y) }

    var scaledSize: CGSize {
        let min = self.min
        let max = self.max
        let size = CGSize(width: max.x - min.x, height: max.y - min.y)
        let scaleX = self.viewScale.width / size.width
        let scaleY = self.viewScale.height / size.height
        return CGSize(width: scaleX, height: scaleY)
    }

    var points: [CGPoint] {
        self.rawPoints.map { $0.point(from: self.scaledOrigin, in: self.scaledSize) }
    }

    var lines: [(CGPoint, CGPoint)] {
        // group by idx for creating new lines
        let grouped: [Int: [MapPoint]] = self.rawPoints.reduce(into: [:], { $0[$1.idx] = ($0[$1.idx] ?? []) + [$1] })

        let pointsOnly = grouped.mapValues { mapPoints in
            (0..<mapPoints.count - 1).map { startId in
                (1..<mapPoints.count).map { endId in
                    (
                        mapPoints[startId].point(from: self.scaledOrigin, in: self.scaledSize),
                        mapPoints[endId].point(from: self.scaledOrigin, in: self.scaledSize)
                    )
                }
            }
            .flatMap { $0 }
        }

        return pointsOnly.values.flatMap { $0 }
    }

    lazy var min: CGPoint = {
        .init(x: self.rawPoints.min(by: { $0.long < $1.long })?.long ?? 0,
              y: self.rawPoints.min(by: { $0.lat < $1.lat })?.lat ?? 0)
    }()

    lazy var max: CGPoint = {
        .init(x: self.rawPoints.max(by: { $0.long < $1.long })?.long ?? 0,
              y: self.rawPoints.max(by: { $0.lat < $1.lat })?.lat ?? 0)
    }()

    lazy var rawSize: CGSize = {
        let min = self.min
        let max = self.max
        return .init(width: max.x - min.x, height: max.y - min.y)
    }()

    lazy var rawPoints: [MapPoint] = {
        self.contents?
            .split(separator: "\n")
            .map { self.splitRow(string: $0) }
            .compactMap(MapPoint.init(array:)) ?? []
    }()

    private func splitRow(string: Substring) -> [String] {
        string.split(separator: ",")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private var contents: String? {
        try? self.bordersFile.map(String.init(contentsOfFile:))
    }

    private var bordersFile: String? {
        Bundle.main.path(forResource: "borders", ofType: "csv")
    }
}
