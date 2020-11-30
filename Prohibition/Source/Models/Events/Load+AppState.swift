//
//  LoadMarkets.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/29/20.
//

import Foundation

private struct EntityRecord {
    let entity: Entity
    let city: City
    let inventory: [Inventory]
    let capital: Money
}

extension AppState {

    static func random() -> AppState {
        let user = Self.randomUser()
        let all = City.allCases.map(\.randomStarter).flatMap { $0 } + [user]

        return .init(
            cities: City.allCases,
            entities: all.map(\.entity),
            events: [],
            basePrices: City.allCases.reduce(into: [:], { $0[$1] = $1.randomBasePrices() }),
            inventories: all.reduce(into: [:], { $0[$1.entity] = $1.inventory }),
            capital: all.reduce(into: [:], { $0[$1.entity] = $1.capital }),
            locations: all.reduce(into: [:], { $0[$1.city] = ($0[$1.city] ?? []) + [$1.entity] }),
            user: user.entity
        )
    }

    private static func randomUser() -> EntityRecord {
        .init(entity: .newUser, city: .smallest, inventory: [], capital: Money.Category.midrange.randomPrice)
    }
}

private extension City {
    static let smallest = City.allCases.sorted { $0.props.population < $1.props.population }.first ?? .nashville

    var randomStarter: [EntityRecord] {
        return (0..<self.size.citizens).map { _ in self.randomCitizen() }
            + (0..<self.size.resources).map { _ in self.randomResource() }
    }

    func randomResource() -> EntityRecord {
        let entity = Entity.randomResource()

        assert(entity.product != nil, "Expected product on a natural resource")

        let product = entity.product ?? .random()

        let supply = Inventory(product: product,
                               brand: product.randomBrand,
                               type: .supply,
                               quantity: product.category.randomQuantity())

        return .init(entity: entity, city: self, inventory: [supply], capital: .random())
    }

    func randomCitizen() -> EntityRecord {
        let demands: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterCitizenDemand()) }
            .map { .init(product: $0, brand: $0.randomBrand, type: .demand, quantity: $0.category.randomQuantity()) }

        let supplies: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterResource()) }
            .map { .init(product: $0, brand: $0.randomBrand,  type: .supply, quantity: $0.category.randomQuantity()) }

        return .init(entity: .randomCitizen(), city: self, inventory: demands + supplies, capital: .random())
    }

    func randomBasePrices() -> [Product: Money] {
        Product.allCases.reduce(into: [:], { $0[$1] = $1.priceCategory.randomPrice })
    }
}
