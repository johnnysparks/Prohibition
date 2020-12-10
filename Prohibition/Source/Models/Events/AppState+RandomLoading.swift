//
//  AppState+RandomLoading.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/29/20.
//

extension AppState {
    static func random() -> AppState {
        let user = Self.randomUser()
        let records: [EntityRecord] = City.allCases.map(\.randomStarter).flatMap { $0 } + [user]

        var inventories: [City: [Entity: [Inventory]]] = [:]

        records.forEach { r in
            inventories[r.city] = inventories[r.city] ?? [:]
            inventories[r.city]?[r.entity] = r.inventory
        }

        let locations: [Entity: City] = records.reduce(into: [:]) { $0[$1.entity] = $1.city }

        return .init(
            cities: City.allCases,
            entities: records.map(\.entity),
            events: [],
            inventories: inventories,
            capital: records.reduce(into: [:], { $0[$1.entity] = $1.capital }),
            locations: locations,
            user: user.entity
        )
    }

    private static func randomUser() -> EntityRecord {
        .init(entity: .newUser, city: .smallest, inventory: [], capital: Product.Quality.midrange.randomPrice)
    }
}

private struct EntityRecord {
    let entity: Entity
    let city: City
    let inventory: [Inventory]
    let capital: Money
}

extension Array where Element == Inventory {
    func combining(other: [Inventory]) -> [Inventory] {
        var supply: [Product: [Inventory]] = [:]
        var demand: [Product: [Inventory]] = [:]

        for i in self + other {
            if i.type == .demand {
                demand[i.product] = (demand[i.product] ?? []) + [i]
            } else {
                supply[i.product] = (supply[i.product] ?? []) + [i]
            }
        }

        return []
    }
}

private extension City {
    static let smallest = City.allCases.min { $0.props.population < $1.props.population } ?? .nashville

    var randomStarter: [EntityRecord] {
        return (0..<self.size.citizens).map { _ in self.randomCitizen() }
    }

    func randomCitizen() -> EntityRecord {
        // Pent up energy at the start!
        let entity = Entity.random()
        let p = entity.personality
        let capital = Money.random(in: p.props.capital)

        let demands = (0..<3).compactMap { _ in p.randomInventory(type: .demand) }
        let supplies = (0..<3).compactMap { _ in p.randomInventory(type: .supply) }

        return .init(entity: entity, city: self, inventory: demands + supplies, capital: capital)
    }

    func randomBasePrices() -> [Product: Money] {
        Product.allCases.reduce(into: [:], { $0[$1] = $1.props.quality.randomPrice })
    }
}

private extension Personality {
    func randomInventory(type: Inventory.InventoryType) -> Inventory? {
        let categories = type == .supply ? self.props.produces : self.props.demands

        guard let category = categories.randomElement() else { return nil }

        let product = category.randomProduct()
        let quantity = category.randomVolume()

        guard quantity > 0 else { return nil }

        return .init(product: product, brand: product.randomBrand, type: type,
                     quantity: quantity, bid: product.props.quality.randomPrice)
    }
}
