//
//  AppEnvironment.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/1/20.
//

import ComposableArchitecture

typealias RandomEventProducer = (TimeInterval, AnySchedulerOf<DispatchQueue>) -> Effect<AppAction, Never>

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    var random: RandomEventProducer = { sec, scheduler in
        Effect<AppAction, Never>(value: AppAction.random())
            .delay(for: .seconds(sec), scheduler: scheduler)
            .eraseToEffect()
    }
}
