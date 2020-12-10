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

struct Entity: Equatable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let personality: Personality

    static let newUser = Entity(id: UUID(), name: "PLAYER", personality: .user)
}

extension Entity: RandomExample {
    static func random() -> Self {
        .init(id: .init(), name: randomName(), personality: .random())
    }
}

extension Entity: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(self.name) - \(self.id), \(self.personality)"
    }
}

enum Personality: String, CaseIterable, Equatable {
    case alcoholic = "Alcoholic"
    case brewer = "Brewer"
    case farmer = "Farmer"
    case machinist = "Machinist"
    case miner = "Miner"
    case speculator = "Speculator"
    case user = "You"

    var frequency: Float { self.props.frequency }
    var produces: [Product.Category] { self.props.produces }
    var demands: [Product.Category] { self.props.demands }

    //swiftlint:disable line_length comma
    var props: (icon: String, frequency: Float, capital: Range<Money>, produces: [Product.Category], demands: [Product.Category]) {
        switch self {
        case .alcoholic:    return ("drop.triangle",        0.1, 90_00..<100_00,    [],                [.consumable])
        case .brewer:       return ("eyedropper.halffull",  0.5, 5_00..<10_00,      [.consumable],     [.ingredient])
        case .farmer:       return ("sun.haze",             0.5, 1_00..<5_00,       [.ingredient],     [.equipment, .consumable])
        case .machinist:    return ("wrench",               0.1, 5_00..<10_00,      [.equipment],      [.equipmentParts, .consumable])
        case .miner:        return ("hammer",               0.3, 5_00..<10_00,      [.equipmentParts], [.consumable])
        case .speculator:   return ("dollarsign.circle",    0.1, 500_00..<900_00,   [],                Product.Category.allCases)
        case .user:         return ("person.circle",        0.0, 5_00..<10_00,      [],                [])
        }
    }
}

extension Personality: RandomExample {
    static func random() -> Self {
        var bound: Float = 0
        var ranges: [(Range<Float>, Personality)] = []

        Personality.allCases.forEach {
            let range = bound..<bound + $0.frequency
            bound = range.upperBound
            ranges.append((range, $0))
        }

        let random = Float.random(in: 0...bound)
        return ranges.first(where: { $0.0.contains(random) })?.1 ?? .farmer
    }
}

extension Product.Category {
    func randomVolume() -> Int {
        switch self {
        case .ingredient:
            return Int.random(in: 0...3)
        case .consumable:
            return Int.random(in: 0...2) == 0 ? 1 : 0
        case .equipmentParts:
            return Int.random(in: 0...5) == 0 ? 1 : 0
        case .equipment:
            return Int.random(in: 0...20) == 0 ? 1 : 0
        }
    }
}
