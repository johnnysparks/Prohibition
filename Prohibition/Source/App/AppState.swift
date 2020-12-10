//
//  AppStore.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/25/20.
//

import ComposableArchitecture

// MARK: - State

struct AppState: Equatable {
    // Lists
    var cities: [City] = []
    var entities: [Entity] = []
    var events: [AppAction] = []

    // Market Calculation
    var marketHistory: [City: [Product: [MarketSummary]]] = [:]
    var inventories: [City: [Entity: [Inventory]]] = [:]
    var capital: [Entity: Money] = [:]
    var locations: [Entity: City] = [:]

    // Player
    var user: Entity = .newUser

    // Time
    var ticks: Int = 0
}

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    state.events.append(action)

    switch action {
    case .load(let full):
        state = full
    case .trade(let trades):
        state.apply(trades: trades)
    case .production(let productions):
        state.apply(productions: productions)
    case .travel(let travel):
        state.locations[travel.entity] = travel.end
        let stuff = state.inventories[travel.start]?[travel.entity] ?? []
        state.inventories[travel.end]?[travel.entity] = stuff
    case .gameTick:
        let productions = state.productionTick()
        state.apply(productions: productions)
        state.events.append(.production(productions))

        let trades = state.tradeTick()
        state.apply(trades: trades)
        state.events.append(.trade(trades))
    }

    return env.gameTick(TimeInterval(10.0), state, env.mainQueue)
}

extension AppState {
    var userCity: City? { self.locations[self.user] }

    // TODO - apply trades
    mutating func apply(trades: [Trade]) {}

    mutating func apply(productions: [Production]) {
        // Build new inventories
        for (city, entityInventories) in self.inventories {
            for (entity, inventories) in entityInventories {
                let next = inventories.map { $0.adding(quantity: productions.supply(of: $0.product, for: entity)) }
                self.inventories[city]?[entity] = next
            }
        }

        // Get min sell price and max buy price for price history
        for (city, entityInventories) in self.inventories {
            var markets: [Product: MarketSummary] = [:]
            for i in entityInventories.flatMap({ $0.value }) {
                markets[i.product] = (markets[i.product] ?? .init(product: i.product)).applying(inventory: i)
            }

            self.marketHistory[city] = self.marketHistory[city] ?? [:]
            for (product, market) in markets {
                let next = (self.marketHistory[city]?[product] ?? []) + [market]
                self.marketHistory[city]?[product] = next
            }
        }
    }
}

private extension Inventory {
    func adding(quantity: Int) -> Inventory {
        .init(product: self.product, brand: self.brand, type: self.type, quantity: self.quantity + quantity,
              bid: self.bid)
    }
}

private extension Array where Element == Production {
    func supply(of product: Product, for entity: Entity) -> Int {
        self.reduce(0) {
            $0 + ($1.entity == entity && $1.inventory.product == product ? $1.inventory.quantity : 0)
        }
    }
}
