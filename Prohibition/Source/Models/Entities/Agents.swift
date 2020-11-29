//
//  Agents.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//
import Foundation

let kPersonNames = [
    "George",
    "Ruth",
    "Joseph",
    "Virginia",
    "Richard",
    "Doris",
    "Edward",
    "Mildred",
    "Donald",
    "Frances",
]

enum Entity: Equatable, RandomExample {
    // Can buy or sell. Consumes consumables
    case citizen(name: String)
    // Only sells raw materials or the occasional lucky manufactured good
    case naturalResource(product: Product)
    case user

    static func random() -> Self { Bool.random() ? .randomCitizen() : .randomResource() }

    static func randomCitizen() -> Self { .citizen(name: kPersonNames.randomElement() ?? "Moe") }

    static func randomResource() -> Self {
        .naturalResource(product: Product.random(in: Product.Category.randomStarterResource()))
    }

    var displayName: String {
        switch self {
        case .citizen(let name):
            return name
        case .naturalResource(let product):
            return product.displayName
        case .user:
            return "PLAYER"
        }
    }

    var isResource: Bool {
        if case .naturalResource = self {
            return true
        } else {
            return false
        }
    }

    var isCitizen: Bool {
        if case .citizen = self {
            return true
        } else {
            return false
        }
    }
}

enum Personality: CaseIterable, Equatable {
    case alcoholic
    case speculator
    case machinist
    case brewer
}

extension Personality: RandomExample {
    static func random() -> Personality {
        Self.allCases.randomElement() ?? .alcoholic
    }
}

struct Trader: Equatable {
    let entity: Entity
    let inventories: [Inventory]
    let capital: Money
    let personality: Personality

    var name: String { self.entity.displayName }
}

extension Trader: RandomExample {
    static func random() -> Self {
        .init(entity: .random(),
              inventories: (1..<3).map { _ in .random() },
              capital: .random(),
              personality: .random())
    }
}
