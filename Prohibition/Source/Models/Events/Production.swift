//
//  Production.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

struct Production: Equatable, RandomExample {
    let producer: Trader
    let recipe: Recipe
    let quantityProduced: Int

    static func random() -> Self {
        .init(producer: .random(), recipe: .random(), quantityProduced: .random(in: 1...5))
    }
}
