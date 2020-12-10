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
    let product: Product
    let price: Money
    let qty: Int

    static func random() -> Self {
        .init(buyer: .random(), seller: .random(), city: .random(), product: .random(), price: .random(),
              qty: .random(in: 0...10))
    }
}

extension AppState {
    func trades(ticks: Int) -> [Trade] {
        (0..<ticks)
            .map { _ in self.tradeTick() }
            .flatMap { $0 }
    }

    func tradeTick() -> [Trade] {
        var trades: [Trade] = []
        for (city, entityInventories) in self.inventories {
            var supplies: [Product: [(Entity, Inventory)]] = [:]

            for (entity, inventories) in entityInventories {
                for item in inventories {
                    supplies[item.product] = supplies[item.product] ?? []
                    supplies[item.product]?.append((entity, item))
                }
            }

            let productTrades = supplies
                .map { TradeTable(city, $0.key, inventories: $0.value).trades() }
                .flatMap { $0 }

            trades.append(contentsOf: productTrades)
        }

        return trades
    }
}

// every demand will have a price and every supply will have a price.
// For every supply price < demand price there will be a sale.
// sort sells by min > max
// sort buys by max > min
// while sell price < buy price, trade units.

// change price history to average price. both buy and sell are equally weighted.

// Clear out the cheapest buyers first, since new random prices mean they'll go state more often
// Clear out the most expensive sellers first, for the same reason

// Example inventories

// Sellers             - Buyers
// S3: sell 5 beer @ $6 - B3: buy 1 beer @ $4
// S2: sell 3 beer @ $3 - B2: buy 2 beer @ $5
// S1: sell 1 beer @ $1 - B1: buy 1 beer @ $8

// S3 sells no beer
// S2 sells 1 beer to B3 @ $3.50 (average price).
    // remove B3 since no more demand
    // reset cursor to end for selling
// S3 sells no beer
// S2 sells 2 beers to B2 @ $4.00 (average price)
    // remove B2 since no demand
    // remove S3 since no supply
    // reset cursors
// S3 sells 1 beer to B1 @ $7.00 (average price)
    // Demand empty. End market trades

class TradeTable {
    let city: City
    let product: Product
    var sellIdx = 0
    var buyIdx = 0
    var supplies: [(entity: Entity, price: Money, qty: Int)] = []
    var demands: [(entity: Entity, price: Money, qty: Int)] = []

    init(_ city: City, _ product: Product, inventories: [(Entity, Inventory)]) {
        self.city = city
        self.product = product
        self.demands = inventories.filter(\.1.isDemand)
            .map { ($0.0, $0.1.bid, $0.1.quantity) }
            .sorted(by: { $0.price < $1.price })
        self.supplies = inventories.filter(\.1.isSupply)
            .map { ($0.0, $0.1.bid, $0.1.quantity) }
            .sorted(by: { $0.price > $1.price })

//        print("demands: \(self.demands)")
//        print("supplies: \(self.supplies)")
    }

    func trades() -> [Trade] {
        var trades: [Trade] = []
        while let next = self.next() {
            trades.append(next)
        }

        return trades
    }

    private func next() -> Trade? {
        // If a trade is made, see if we need another buyer (advance buy idx)
        if let trade = self.tryNext(sellIdx: self.sellIdx, buyIdx: self.buyIdx) {
            self.buyIdx += 1
            return trade
        }

        // If no trade is made check the next seller (advance sell idx, reset sell idx)
        self.sellIdx += 1
        self.buyIdx = 0
        return self.sellIdx >= self.supplies.count ? nil : self.next()
    }

    private func tryNext(sellIdx: Int, buyIdx: Int) -> Trade? {
        guard let sell = self.supplies[safe: sellIdx],
              let buy = self.demands[safe: buyIdx],
              sell.qty > 0,
              buy.qty > 0 else {
            return nil
        }

        // we have a sale!
        if sell.price < buy.price {
            let tradeSize = min(sell.qty, buy.qty)

            // todo, verify available funds
            self.supplies[sellIdx].qty -= tradeSize
            self.demands[buyIdx].qty -= tradeSize

            return Trade(buyer: buy.entity, seller: sell.entity, city: self.city,
                         product: self.product, price: (sell.price + buy.price) / 2,
                         qty: tradeSize)
        }

        return nil
    }
}
