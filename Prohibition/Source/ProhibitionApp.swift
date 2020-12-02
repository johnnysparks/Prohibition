//
//  ProhibitionApp.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/22/20.
//

import SwiftUI
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

let appStore: Store<AppState, AppAction> = .init(initialState: .init(), reducer: appReducer, environment: AppEnvironment())

@main
struct ProhibitionApp: App {
    var body: some Scene {
        WindowGroup {
            WithViewStore(appStore) { store in
                TabView {
                    CityListView(store: appStore)
                        .tabItem {
                            Image(systemName: "map")
                            Text("Cities")
                        }
                    EventLogView(store: appStore)
                        .tabItem {
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Events")
                        }
                }
                .font(.headline)
                .onAppear {
                    store.send(.load(.random()))
                }
            }
        }
    }
}


