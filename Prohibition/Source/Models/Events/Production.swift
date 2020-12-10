//
//  Production.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

struct Production: Equatable, RandomExample {
    let city: City
    let entity: Entity
    let inventory: Inventory

    static func random() -> Self {
        .init(city: .random(), entity: .random(), inventory: .random())
    }
}

extension AppState {
    func productions(ticks: Int) -> [Production] {
        (0..<ticks)
            .map { _ in self.productionTick() }
            .flatMap { $0 }
    }

    func productionTick() -> [Production] {
        var productions = [Production]()
        self.inventories.forEach { city, entityInventories in
            entityInventories.forEach { entity, inventories in
                let entityProductions = inventories
                    .filter(\.isSupply)
                    .compactMap { $0.production(city: city, entity: entity) }
                productions.append(contentsOf: entityProductions )
            }
        }

        return productions
    }
}

private extension Inventory {
    var productionInventory: Inventory? {
        let qty = self.product.props.category.randomVolume()
        return qty > 0 ? .init(product: self.product, brand: self.brand, type: self.type, quantity: qty,
                               bid: self.bid) : nil
    }

    func production(city: City, entity: Entity) -> Production? {
        self.productionInventory.map { .init(city: city, entity: entity, inventory: $0) }
    }
}
