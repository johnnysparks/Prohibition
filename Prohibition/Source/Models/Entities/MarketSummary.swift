//
//  MarketSummary.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/5/20.
//

import Foundation

struct MarketSummary: Equatable {
    let product: Product
    let supplyQty: Int
    let demandQty: Int
    let sell: Money
    let buy: Money

    var hasSupply: Bool { self.supplyQty > 0 }
    var hasDemand: Bool { self.demandQty > 0 }

    init(product: Product, supplyQty: Int = 0, demandQty: Int = 0, sell: Money? = nil, buy: Money? = nil) {
        self.product = product
        self.supplyQty = supplyQty
        self.demandQty = demandQty
        self.sell = sell ?? product.props.quality.range.upperBound  // sell demand
        self.buy = buy ?? product.props.quality.range.lowerBound // buy supply
    }

    func applying(inventory: Inventory) -> MarketSummary {
        .init(
            product: self.product,
            supplyQty: self.supplyQty + (inventory.isSupply ? inventory.quantity : 0),
            demandQty: self.demandQty + (inventory.isDemand ? inventory.quantity : 0),
            sell: inventory.isDemand ? min(inventory.bid, self.sell) : self.sell,
            buy: inventory.isSupply ? max(inventory.bid, self.buy) : self.buy
        )
    }
}
