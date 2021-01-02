//
//  HexTile.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/1/21.
//

import Foundation

extension HexGrid {
    struct Tile: Hashable {
        enum Content {
            case road
            case delivery
            case state
//            case city(City)
        }

        let contents: [Content]
        let cell: Cell
    }
}
