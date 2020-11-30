//
//  AppStore.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/25/20.
//

import Foundation
import ComposableArchitecture

// MARK: - State

struct AppState: Equatable {
    // Lists
    var cities: [City] = []
    var entities: [Entity] = []
    var events: [AppAction] = []

    // Market Calculation
    var basePrices: [City: [Product: Money]] = [:]
    var inventories: [Entity: [Inventory]] = [:]
    var capital: [Entity: Money] = [:]
    var locations: [City: [Entity]] = [:]

    // Player
    var user: Entity = .newUser
}

extension AppState {
    func price(for product: Product, in city: City) -> Money {
        // price is determined by total available inventory and total demand
        // each market has a "unit price" per product where units of supply == units of demand
        // the maximum supply for any resource == 99
        // the minimum supply for any resource == 0
        // the affordability of each item determines the top and bottom price when demand >>> supply or vice versa

        let (supply, demand) = self.supplyAndDemand(for: product, in: city)
        let basePrice = self.basePrices[city]?[product] ?? product.priceCategory.randomPrice
        let priceRange = product.priceCategory.range
        let priceSpread = Float(priceRange.upperBound - priceRange.lowerBound)

        // supply = demand = unit. 100 demand - 0 supply = max shift. 0 demand - 100 supply = minimized price
        let fractionalMarketBalance = Float(demand - supply) / 100.0

        // center the price range of the category on the base price and shift it by the fractional market balance amount.
        // (multiply the fractionalMarketBalance against the price range and add it to the base price)
        return basePrice + Int(fractionalMarketBalance * priceSpread)
    }

    private func supplyAndDemand(for product: Product, in city: City) -> (supply: Int, demand: Int) {
        self.inventories(for: product, in: city)
            .reduce((0, 0)) { ($0.0 + $1.supply, $0.1 + $1.demand) }
    }

    func inventories(for product: Product, in city: City) -> [Inventory] {
        (self.locations[city] ?? [])
            .compactMap { self.inventories[$0]?.filter { $0.product == product } }
            .flatMap { $0 }
    }

    func inventories(in city: City) -> [Inventory] {
        (self.locations[city] ?? [])
            .compactMap { self.inventories[$0] }
            .flatMap { $0 }
    }

    func supplies(in city: City) -> [(Product, Int)] {
        self.inventories(in: city).supplies
    }

    func demands(in city: City) -> [(Product, Int)] {
        self.inventories(in: city).demands
    }

    var userCity: City? { self.locations.first { $1.contains(where: \.isUser) }?.key }
}

private extension Array where Element == Inventory {
    var supplies: [(Product, Int)] {
        self.filter(\.isSupply).reduce(into: [Product: Int]()) { $0[$1.product] = ($0[$1.product] ?? 0) + $1.quantity }
            .map { ($0.key, $0.value) }
            .filter { $1 > 0 }
    }

    var demands: [(Product, Int)] {
        self.filter(\.isDemand).reduce(into: [Product: Int]()) { $0[$1.product] = ($0[$1.product] ?? 0) + $1.quantity }
            .map { ($0.key, $0.value) }
            .filter { $1 > 0 }
    }
}
