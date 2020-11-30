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

struct Entity: Equatable, Hashable, RandomExample {
    enum EntityType: Equatable, Hashable {
        case citizen(name: String)
        case resource(product: Product)
        case user
    }

    let id: UUID
    let type: EntityType
    let personality: Personality

    static let newUser = Entity(id: UUID(), type: .user, personality: .user)

    static func random() -> Self { Bool.random() ? .randomCitizen() : .randomResource() }

    static func randomCitizen() -> Self {
        .init(id: UUID(), type: .citizen(name: kPersonNames.randomElement() ?? "Moe"), personality: .random())

    }

    static func randomResource() -> Self {
        .init(id: UUID(),
              type: .resource(product: Product.random(in: .randomStarterResource())),
              personality: .random())
    }

    var displayName: String {
        switch self.type {
        case .citizen(let name):
            return name
        case .resource(let product):
            return product.displayName
        case .user:
            return "PLAYER"
        }
    }

    var isResource: Bool {
        if case .resource = self.type {
            return true
        } else {
            return false
        }
    }

    var isUser: Bool {
        if case .user = self.type {
            return true
        } else {
            return false
        }
    }


    var product: Product? {
        if case .resource(let product) = self.type {
            return product
        } else {
            return nil
        }
    }

    var isCitizen: Bool {
        if case .citizen = self.type {
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
    case user
}

extension Personality: RandomExample {
    static func random() -> Personality {
        Self.allCases.randomElement() ?? .alcoholic
    }
}

struct Trader: Equatable {
    let city: City
    let entity: Entity
    let inventories: [Inventory]
    let capital: Money

    var name: String { self.entity.displayName }
}

extension Trader: RandomExample {
    static func random() -> Self {
        self.random(city: .random())
    }

    static func random(city: City) -> Self {
        .init(city: city,
              entity: .random(),
              inventories: (1..<3).map { _ in .random() },
              capital: .random())
    }
}
