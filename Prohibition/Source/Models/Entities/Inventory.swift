//
//  Inventory.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

/// A supply of a particular product & brand
struct Inventory: Equatable, RandomExample  {
    let product: Product
    let brand: Brand?
    let supply: Int
    let demand: Int

    static func random() -> Self {
        let recipe = Recipe.random()
        return .init(product: recipe.product,
                     brand: recipe.brand,
                     supply: .random(in: 1...20),
                     demand: .random(in: 1...20))
    }
}
