//
//  appReducer.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/30/20.
//

import Foundation
import ComposableArchitecture

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    switch action {
    case .load(let full):
        state = full
    case .trade, .production:
        state.events.append(action)
    case .travel(let travel):
        state.locations[travel.from] = state.locations[travel.from]?.filter { $0 != travel.entity }
        state.locations[travel.to]?.append(travel.entity)

        state.events.append(action)
    }

    return env.random(TimeInterval(20.0), env.mainQueue)
}
