//
//  Events.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

struct Trade: Equatable, RandomExample {
    let buyer: Entity
    let seller: Entity
    let city: City
    let inventory: Inventory
    let price: Money

    static func random() -> Self {
        .init(buyer: Entity.random(), seller: Entity.random(), city: City.random(),
              inventory: .random(), price: .random())
    }
}

extension AppState {
    func trades(ticks: Int) -> [Trade] {
        (0..<ticks)
            .map { _ in self.tradeTick() }
            .flatMap { $0 }
    }

    func tradeTick() -> [Trade] {
        return []
//        self.inventories
//            .filter(\.key.isResource)
//            .map { entity, inventory -> [Trade] in
//                return []
//                let all = inventory
//                    .compactMap { $0.production(entity: entity) }
//            }
//            .flatMap { $0 }
    }
}

// demands

// supplies
