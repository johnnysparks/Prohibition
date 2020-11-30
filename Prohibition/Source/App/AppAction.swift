//
//  AppAction.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/30/20.
//

import Foundation

// MARK: - Actions

enum AppAction: Equatable {
    case trade(Trade)
    case production(Production)
    case load(AppState)
    case travel(Travel)
}

extension AppAction: RandomExample {
    static func random() -> Self {
        Bool.random() ? .trade(.random()) : .production(.random())
    }
}
