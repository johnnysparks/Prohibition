//
//  Price.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation

typealias Money = Int

extension Money {
    var display: String {
        switch self {
        case ..<0:
            return "None"
        case 1..<100:
            return "¢\(self)"
        default:
            return "$\(self / 100)"
        }

    }
}

extension Money: RandomExample {
    static func random() -> Self {
        Money.random(in: 5_00...100_00)
    }
}

extension Money {
    enum Category: Equatable {
        case cheap
        case affordable
        case midrange
        case expensive
        case exorbitant

        var randomPrice: Money { .random(in: self.range) }

        var range: ClosedRange<Money> {
            switch self {
            case .cheap:
                return 1...2_00
            case .affordable:
                return 0_75...5_00
            case .midrange:
                return 5_00...50_00
            case .expensive:
                return 50_00...100_00
            case .exorbitant:
                return 100_00...10_000_00
            }
        }
    }
}
