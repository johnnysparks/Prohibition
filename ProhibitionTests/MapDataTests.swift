//
//  MoneyTests.swift
//  ProhibitionTests
//
//  Created by Johnny Sparks  on 11/22/20.
//

@testable import Prohibition
import XCTest

class MapTests: XCTestCase {
    func testLoadData() {
        XCTAssertEqual(791, LegacyMapData(scale: .init(width: 100, height: 100)).points.count)
    }

    func testMapSize() {
        let size = LegacyMapData(scale: .init(width: 100, height: 100)).rawSize
        XCTAssertEqual(size.width, 53.5, accuracy: 0.1)
        XCTAssertEqual(size.height, 19, accuracy: 0.1)
    }

    func testMapScaledPoints() {
        let map = LegacyMapData(scale: .init(width: 100, height: 100))
        let points = map.points
        let minX = points.min(by: { $0.x < $1.x })?.x ?? 0
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? 0

        let minY = points.min(by: { $0.y < $1.y })?.y ?? 0
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? 0

        XCTAssertEqual(minY, 0, accuracy: 0.01)
        XCTAssertEqual(maxY, 100, accuracy: 0.01)

        XCTAssertEqual(minX, 0, accuracy: 0.01)
        XCTAssertEqual(maxX, 100, accuracy: 0.01)
    }
}
