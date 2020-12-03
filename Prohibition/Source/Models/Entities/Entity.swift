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
    "Robert",
    "Mary",
    "John",
    "Dorothy",
    "James",
    "Helen",
    "William",
    "Betty",
    "Charles",
    "Margaret",
    "Thomas",
    "Elizabeth",
    "Frank",
    "Evelyn",
    "Harold",
    "Anna",
    "Paul",
    "Marie",
    "Raymond",
    "Alice",
    "Walter",
    "Jean",
    "Jack",
    "Shirley",
]

private func randomName() -> String {
    let first = (kPersonNames.randomElement() ?? "Moe")
    let last = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement().map(String.init) ?? "A"
    return "\(first) \(last)."
}

struct Entity: Equatable, Hashable, RandomExample, Identifiable {
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
        .init(id: UUID(), type: .citizen(name: randomName()), personality: .random())
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
