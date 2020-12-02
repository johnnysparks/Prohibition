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
