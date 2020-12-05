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
            + (0..<self.size.resources).map { _ in self.randomResource() }
    }

    func randomResource() -> EntityRecord {
        let entity = Entity.randomResource()

        assert(entity.product != nil, "Expected product on a natural resource")

        let product = entity.product ?? .random()

        let supply = Inventory(product: product,
                               brand: product.randomBrand,
                               type: .supply,
                               quantity: product.props.category.randomQuantity(),
                               bid: product.props.quality.randomPrice)

        return .init(entity: entity, city: self, inventory: [supply], capital: .random())
    }

    func randomCitizen() -> EntityRecord {
        let demands: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterCitizenDemand()) }
            .map { .randomInventory($0, .demand) }

        let supplies: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterResource()) }
            .map { .randomInventory($0, .supply) }

        return .init(entity: .randomCitizen(), city: self, inventory: demands + supplies, capital: .random())
    }

    func randomBasePrices() -> [Product: Money] {
        Product.allCases.reduce(into: [:], { $0[$1] = $1.props.quality.randomPrice })
    }
}

private extension Inventory {
    static func randomInventory(_ product: Product, _ type: InventoryType) -> Inventory {
        .init(product: product,
              brand: product.randomBrand,
              type: type,
              quantity: product.props.category.randomQuantity(),
              bid: product.props.quality.randomPrice)
    }
}
