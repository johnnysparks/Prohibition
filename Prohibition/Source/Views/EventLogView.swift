//
//  ContentView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/22/20.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct EventLogView: View {
    struct ViewState: Equatable {
        let title = "Event Log"
        let entries: [EntryView.ViewState]
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.viewState)) { state in
            NavigationView {
                List(state.entries, id: \.hashValue) { entry in
                    EntryView(state: entry)
                }
                .navigationTitle(state.title)

            }.onAppear {
                state.send(.random())
            }
        }
    }

    struct EntryView: View {
        struct ViewState: Equatable, Hashable {
            let icon: String
            let title: String
            let detail: String
        }

        var state: ViewState

        var body: some View {
            HStack(alignment: .top) {
                Image(systemName: state.icon)
                    .font(.caption)

                VStack(alignment: .leading) {
                    Text(state.title)
                        .font(.caption)
                        .bold()

                    Text(state.detail)
                        .font(.caption)
                }
            }
        }
    }
}

private extension AppState {
    var viewState: EventLogView.ViewState { .init(entries: self.events.map(\.viewState)) }
}

private extension AppAction {
    var viewState: EventLogView.EntryView.ViewState {
        switch self {
        case .production(let production):
            return production.viewState
        case .trade(let trade):
            return trade.viewState
        case .load(let state):
            return .init(icon: "cart", title: "Setup markets", detail: "\(state.events.count) events loaded")
        case .travel(let travel):
            return .init(icon: "airplane", title: "\(travel.entity.displayName) on the move", detail: "Went from \(travel.from.name) to \(travel.to.name)")
        }
    }
}

private extension Production {
    var viewState: EventLogView.EntryView.ViewState {
        .init(icon: "hammer.fill",
              title: "\(self.inventory.quantity) units of \(self.inventory.product.displayName) made by \(self.entity.displayName)",
              detail: "unknown total reagents consumed")
    }
}

private extension Trade {
    var viewState: EventLogView.EntryView.ViewState {
        .init(icon: "arrow.right.arrow.left",
              title: "\(self.inventory.product.displayName) sold in \(self.city.name)!",
              detail: "\(self.buyer.name) paid \(self.price.display) to \(self.seller.name) for \(self.inventory.quantity) units")
    }
}

// MARK: Previews

private let previewStore = Store<AppState, AppAction>(initialState: .init(),
                                                      reducer: appReducer,
                                                      environment: AppEnvironment())

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView(store: previewStore)
    }
}
