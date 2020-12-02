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
extension AppState {
    func productions(ticks: Int) -> [Production] {
        (0..<ticks)
            .map { _ in self.productionTick() }
            .flatMap { $0 }
    }

    func productionTick() -> [Production] {
        self.inventories
            .filter(\.key.isResource)
            .map { entity, inventory -> [Production] in
                inventory.filter(\.isSupply)
                    .compactMap { $0.production(entity: entity) }
            }
            .flatMap { $0 }
    }
}

private extension Inventory {
    var productionInventory: Inventory? {
        let qty = self.product.props.category.randomProduction()
        return qty > 0 ? .init(product: self.product, brand: self.brand, type: self.type, quantity: qty) : nil
    }

    func production(entity: Entity) -> Production? {
        self.productionInventory.map { .init(entity: entity, inventory: $0) }
    }
}
