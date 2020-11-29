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
