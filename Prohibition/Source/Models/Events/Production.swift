//
//  Production.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

struct Production: Equatable, RandomExample {
    let entity: Entity
    let inventory: Inventory

    static func random() -> Self {
        .init(entity: .random(), inventory: .random())
    }
}

// TODO: Right here, spit out productions based on number of days passed
extension Trader {
    func productions(in interval: TimeInterval) -> [Production] {
        return []
    }
}
