//
//  Inventory.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

/// A supply of a particular product & brand
struct Inventory: Equatable, RandomExample {
    enum InventoryType: Equatable {
        case supply
        case demand
    }

    let product: Product
    let brand: Brand?
    let type: InventoryType
    let quantity: Int
    let bid: Money

    var isSupply: Bool { self.type == .supply }
    var isDemand: Bool { self.type == .demand }
    var supply: Int { self.isSupply ? self.quantity : 0 }
    var demand: Int { self.isDemand ? self.quantity : 0 }

    static func random() -> Self {
        let recipe = Recipe.random()
        return .init(product: recipe.product,
                     brand: recipe.brand,
                     type: Bool.random() ? .supply : .demand,
                     quantity: .random(in: 1...20),
                     bid: recipe.product.props.quality.randomPrice)
    }
}
