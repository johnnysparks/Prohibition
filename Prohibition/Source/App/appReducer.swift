//
//  appReducer.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/30/20.
//

import ComposableArchitecture
import Foundation

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    switch action {
    case .load(let full):
        state = full
    case .trade:
        break
    case .production(let productions):
        for (entity, inventories) in state.inventories {
            let next = inventories.map { $0.adding(quantity: productions.supply(of: $0.product, for: entity)) }
            state.inventories[entity] = next
        }

    case .travel(let travel):
        state.locations[travel.start] = state.locations[travel.start]?.filter { $0 != travel.entity }
        state.locations[travel.end]?.append(travel.entity)
    }

    state.events.append(action)

    return env.produceAfter(TimeInterval(10.0), state, env.mainQueue)
}

private extension Inventory {
    func adding(quantity: Int) -> Inventory {
        .init(product: self.product, brand: self.brand, type: self.type, quantity: self.quantity + quantity)
    }
}

private extension Array where Element == Production {
    func supply(of product: Product, for entity: Entity) -> Int {
        self.reduce(0) {
            $0 + ($1.entity == entity && $1.inventory.product == product ? $1.inventory.quantity : 0)
        }
    }
}
