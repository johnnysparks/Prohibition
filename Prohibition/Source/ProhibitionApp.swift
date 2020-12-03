//
//  ProhibitionApp.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/22/20.
//

import ComposableArchitecture
import SwiftUI

let appStore = Store<AppState, AppAction>(
    initialState: .init(),
    reducer: appReducer,
    environment: AppEnvironment()
)

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
                    EntityListView(store: appStore)
                        .tabItem {
                            Image(systemName: "person.3")
                            Text("Citizens")
                        }
                    PlayerDetailView(store: appStore)
                        .tabItem {
                            Image(systemName: "person")
                            Text("Player")
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
