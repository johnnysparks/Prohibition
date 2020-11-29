//
//  Events.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

struct Trade: Equatable, RandomExample {
    let buyer: Trader
    let seller: Trader
    let market: Market
    let inventory: Inventory
    let price: Money

    static func random() -> Self {
        .init(buyer: Trader.random(), seller: Trader.random(), market: Market.random(),
              inventory: .random(), price: .random())
    }
}
