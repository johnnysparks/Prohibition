//
//  ContentView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/22/20.
//

import ComposableArchitecture
import SwiftUI

struct EventLogState: Equatable {
    let title = "Event Log"
    let entries: [EventLogEntryState]
}

struct EventLogEntryState: Equatable, Hashable {
    let icon: String
    let name: String
    let title: String
    let detail: String
    let itemized: [String]
}

struct EventLogView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.viewState)) { state in
            NavigationView {
                List(state.entries, id: \.hashValue) { entry in
                    NavigationLink(destination: EventLogDetailView(state: entry)) {
                        EventLogEntryView(state: entry)
                    }
                }
                .navigationTitle(state.title)
            }
        }
    }
}

struct EventLogEntryView: View {
    var state: EventLogEntryState

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

private extension AppState {
    var viewState: EventLogState { .init(entries: self.events.map(\.viewState)) }
}

private extension AppAction {
    var viewState: EventLogEntryState {
        switch self {
        case .production(let productions):
            return productions.viewState
        case .trade(let trades):
            return trades.viewState
        case .load(let state):
            return .init(icon: "cart",
                         name: "Restore Game",
                         title: "Setup markets",
                         detail: "\(state.events.count) events loaded",
                         itemized: state.events.map(\.viewState.title))
        case .travel(let travel):
            return .init(icon: "airplane",
                         name: "Travel",
                         title: "\(travel.entity.name) is on the move",
                         detail: "Went from \(travel.start.name) to \(travel.end.name)",
                         itemized: [])
        case .gameTick(let date):
            return .init(icon: "clock",
                         name: "Game tick",
                         title: "Game ticked, trigger time-lapse events",
                         detail: "Original time: \(date)", itemized: [])
        }
    }
}

private extension Array where Element == Production {
    var viewState: EventLogEntryState {
        .init(
            icon: "hammer.fill",
            name: "Productions",
            title: self.title,
            detail: self.detail,
            itemized: self.map(\.eventLogDisplay)
        )
    }

    private var title: String { "\(qty) units of produced" }
    private var detail: String { "\(products) different products by \(entities) producers" }
    private var qty: Int { self.map(\.inventory.quantity).reduce(0, +) }
    private var products: Int { Set(self.map(\.inventory.product)).count }
    private var entities: Int { Set(self.map(\.entity)).count }
}

private extension Production {
    var eventLogDisplay: String {
        "\(entity.name) made \(inventory.quantity) \(inventory.product.displayName) in \(city.name)"
    }
}

private extension Array where Element == Trade {
    var viewState: EventLogEntryState {
        .init(
            icon: "arrow.right.arrow.left",
            name: "Trades",
            title: self.title,
            detail: self.detail,
            itemized: self.map(\.eventLogDisplay)
        )
    }

    private var title: String { "\(qty) items traded for \(value.display)" }
    private var detail: String { "\(traders) exchanged \(products) products" }
    private var value: Money { self.map({ Money($0.qty) * $0.price }).reduce(0, +) }
    private var qty: Int { self.map(\.qty).reduce(0, +) }
    private var products: Int { Set(self.map(\.product)).count }
    private var traders: Int { Set(self.map(\.buyer)).count }
}

private extension Trade {
    var eventLogDisplay: String {
        "\(buyer.name) buys \(qty) \(product.displayName) @ \(price.display) from \(seller.name)"
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
