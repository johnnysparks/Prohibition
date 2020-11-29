//
//  AppStore.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/25/20.
//

import Foundation
import ComposableArchitecture

// MARK: - State

struct AppState: Equatable {
    var markets = Market.all
    var events: [AppAction] = []
//    var tab: AppTab = .markets
}

// MARK: - Actions
//enum AppTab {
//    case log
//    case markets
//}

enum AppAction: Equatable {
//    case navigate(AppTab)
    case trade(Trade)
    case production(Production)
}

extension AppAction: RandomExample {
    static func random() -> Self {
        Bool.random() ? .trade(.random()) : .production(.random())
    }
}

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    state.events.append(action)
    return env.random(TimeInterval(2.0), env.mainQueue)
}
