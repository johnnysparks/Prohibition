//
//  CityMapData.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import Foundation

struct CityMapData {
    let collection: StateCollection
    let hexGrid: HexGrid

    var rawCities: [City] {
        switch self.collection {
        case .all, .continuous:
            return City.allCases
        case .california, .westCoast:
            return []
        case .jersey, .rhodeIsland:
            return []
        case .newYork:
            return [.newYork]
        case .gulf:
            return [.atlanta, .jacksonville]
        case .eastern:
            return [
                .cincinnati,
                .indianapolis,
                .louisville,
                .stLouis,
                .nashville,
                .atlanta,
                .charlotte,
                .columbus,
                .pittsburgh,
                .philadelphia,
                .newYork,
                .boston,
                .baltimore,
                .cleveland,
                .detroit,
                .chicago,
                .milwaukee,
                .jacksonville,
                .richmond,
                .knoxvile,
            ]

        case .midwest:
            return [.chicago, .detroit, .milwaukee]
        }
    }

    var geometries: [HexGeometry] {
        self.rawCities.map { city in
            let cell = self.hexGrid.cell(from: city.gps.invertedLatitude.scaledUniformly(100))
            // Corners always produce a valid path, can safely force unwrap
            let path = self.hexGrid.corners(for: cell).map(\.point).toCGPath!
            return HexGeometry(grid: self.hexGrid, cells: Set([cell]), focus: cell, description: city.name, path: path)
        }
    }
}
