//
//  Models.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/25/20.
//

import Foundation

/// Definition of the precursors required for a particular product/brand
struct Recipe: Equatable {
    /// Raw materials to create another product
    struct Precursor: Equatable {
        let product: Product
        let quantityRequired: Int
        let quantityConsumed: Int
    }

    let brand: Brand?
    let product: Product
    let precursors: [Precursor]
}

// MARK: - RandomExample

extension Recipe: RandomExample {
    static func random() -> Self {
        let product = Product.random()
        return .init(
            brand: product.isConsumable ? .random() : nil,
            product: product,
            precursors: (1...3).map { _ in .random() }
        )
    }
}

extension Recipe.Precursor {
    static func precursor(for product: Product) -> Recipe.Precursor? {
        switch product.props {
        case (.consumable, _):
            let qty = Int.random(in: 1..<100)
            let random = Product.ingredients.randomElement() ?? .sugar
            return .init(product: random, quantityRequired: qty, quantityConsumed: qty)
        case (.equipment, .exorbitant):
            let qty = Int.random(in: 100..<1000)
            return .init(product: .parts, quantityRequired: qty, quantityConsumed: qty)
        case (.equipment, _):
            let qty = Int.random(in: 1..<100)
            return .init(product: .parts, quantityRequired: qty, quantityConsumed: qty)
        default:
            return nil
        }
    }

    static func random() -> Self {
        let quantityRequired = Int.random(in: 1...3)
        return .init(
            product: .random(),
            quantityRequired: quantityRequired,
            quantityConsumed: Int.random(in: 1...quantityRequired)
        )
    }
}
