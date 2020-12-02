//
//  ContentView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/22/20.
//

import ComposableArchitecture
import SwiftUI

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
        case .production(let productions):
            return productions.viewState
        case .trade(let trade):
            return trade.viewState
        case .load(let state):
            return .init(icon: "cart", title: "Setup markets", detail: "\(state.events.count) events loaded")
        case .travel(let travel):
            return .init(icon: "airplane",
                         title: "\(travel.entity.displayName) on the move",
                         detail: "Went from \(travel.start.name) to \(travel.end.name)")
        }
    }
}

private extension Array where Element == Production {
    var viewState: EventLogView.EntryView.ViewState {
        .init(icon: "hammer.fill", title: self.title, detail: self.detail)
    }

    private var title: String { "\(qty) units of produced" }
    private var detail: String { "\(products) different products by \(entities) producers" }
    private var qty: Int { self.map(\.inventory.quantity).reduce(0, +) }
    private var products: Int { Set(self.map(\.inventory.product)).count }
    private var entities: Int { Set(self.map(\.entity)).count }
}

private extension Trade {
    var viewState: EventLogView.EntryView.ViewState {
        .init(icon: "arrow.right.arrow.left",
              title: "\(self.inventory.product.displayName) sold in \(self.city.name)!",
              detail: "\(buyer.displayName) paid \(price.display) to \(seller.displayName) for \(qty) units")
    }

    private var qty: Int { self.inventory.quantity }
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
