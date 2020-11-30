//
//  LoadMarkets.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/29/20.
//

import Foundation

extension AppState {
    static func random() -> AppState {

        let all = City.allCases.map(\.randomStarter).flatMap { $0 }

        return .init(
            cities: City.allCases,
            entities: all.map(\.entity),
            events: [],
            basePrices: City.allCases.reduce(into: [:], { $0[$1] = $1.randomBasePrices() }),
            inventories: all.reduce(into: [:], { $0[$1.entity] = $1.inventory }),
            capital: all.reduce(into: [:], { $0[$1.entity] = $1.capital }),
            locations: all.reduce(into: [:], { $0[$1.city] = ($0[$1.city] ?? []) + [$1.entity] }))
    }
}


extension City {
    var randomStarter: [(entity: Entity, city: City, inventory: [Inventory], capital: Money)] {
        return (0..<self.size.citizens).map { _ in self.randomCitizen() }
            + (0..<self.size.resources).map { _ in self.randomResource() }
    }

    func randomResource() -> (Entity, City, [Inventory], Money) {
        let entity = Entity.randomResource()

        assert(entity.product != nil, "Expected product on a natural resource")

        let product = entity.product ?? .random()

        let supply = Inventory(product: product,
                               brand: product.randomBrand,
                               type: .supply,
                               quantity: product.category.randomQuantity())

        return (entity, self, [supply], .random())
    }

    func randomCitizen() -> (Entity, City, [Inventory], Money) {
        let demands: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterCitizenDemand()) }
            .map { .init(product: $0, brand: $0.randomBrand, type: .demand, quantity: $0.category.randomQuantity()) }

        let supplies: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterResource()) }
            .map { .init(product: $0, brand: $0.randomBrand,  type: .supply, quantity: $0.category.randomQuantity()) }

        return (.randomCitizen(), self, demands + supplies, .random())
    }

    func randomBasePrices() -> [Product: Money] {
        Product.allCases.reduce(into: [:], { $0[$1] = $1.priceCategory.randomPrice })
    }
}
