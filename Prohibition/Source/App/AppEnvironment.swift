//
//  AppEnvironment.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/1/20.
//

import ComposableArchitecture

typealias GameTickProducer = (TimeInterval, AppState, AnySchedulerOf<DispatchQueue>) -> Effect<AppAction, Never>

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()

    var gameTick: GameTickProducer = { sec, state, scheduler in
        Effect<AppAction, Never>(value: .gameTick(Date()))
            .delay(for: .seconds(sec), scheduler: scheduler)
            .eraseToEffect()
    }
}
