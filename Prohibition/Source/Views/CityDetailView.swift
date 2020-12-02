//
//  CityDetailView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/30/20.
//

import ComposableArchitecture
import SwiftUI

struct CityDetailState: Equatable, Identifiable {
    var id: City { self.city }

    struct OrderState: Equatable, Hashable {
        let product: String
        let description: String
    }

    let name: String
    let city: City
    let population: String
    let isUserHere: Bool
    let resourcesLabel: String
    let tradersLabel: String
    let resourcesCount: Int
    let tradersCount: Int
    let sellNow: [OrderState]
    let buyNow: [OrderState]
    let travel: Travel?
}

struct CityDetailView: View {
    enum TradeStyle: Int, CaseIterable, Hashable, Identifiable {
        var id: Self { self }

        case buy
        case sell

        var title: String {
            switch self {
            case .buy: return "Buy"
            case .sell: return "Sell"
            }
        }
    }

    @State var tradeStyle: TradeStyle = .buy

    var city: City
    let store: Store<AppState, AppAction>

    private let gridLayout: [GridItem] = (0..<3).map { _ in .init(.flexible()) }

    var body: some View {
        WithViewStore(self.store.scope(state: { $0.cityDetailState(for: self.city) })) { state in
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    HStack {
                        Image(systemName: "person.3")
                        Text(state.population)
                    }
                    HStack {
                        Image(systemName: "hand.raised")
                        Text(state.tradersLabel)
                    }

                    HStack {
                        Image(systemName: "flame")
                        Text(state.resourcesLabel)
                    }
                }
                .frame(maxWidth: .infinity)

                Picker(selection: self.$tradeStyle, label: Text("Buy or Sell")) {
                    ForEach(TradeStyle.allCases) { style in
                        Text(style.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: self.gridLayout, spacing: 20) {
                        ForEach(self.tradeStyle == .sell ? state.sellNow : state.buyNow, id: \.hashValue) { order in
                            VStack {
                                Text(order.product)
                                    .font(.subheadline)
                                    .bold()

                                Text(order.description)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle(state.name)
            .navigationBarItems(trailing: VStack(alignment: .trailing) {
                Image(systemName: "person.circle")
                    .foregroundColor(Color.blue)
                    .showIf(state.isUserHere)

                Button("Travel Here") {
                    if let travel = state.travel {
                        state.send(.travel(travel))
                    }
                }
                .hidden(state.isUserHere)
            })
        }
    }
}

extension AppState {
    func cityDetailState(for city: City) -> CityDetailState {
        let resourcesCount = self.locations[city, default: []].filter(\.isResource).count
        let tradersCount = self.locations[city, default: []].filter(\.isCitizen).count
        return .init(name: city.name,
              city: city,
              population: "pop. \(city.props.population)",
              isUserHere: self.userCity == city,
              resourcesLabel: "\(resourcesCount) resources",
              tradersLabel: "\(tradersCount) buyers/sellers",
              resourcesCount: resourcesCount,
              tradersCount: tradersCount,
              sellNow: self.sellNow(in: city),
              buyNow: self.buyNow(in: city),
              travel: self.userCity.map { Travel(entity: self.user, start: $0, end: city) }
        )
    }

    private func buyNow(in city: City) -> [CityDetailState.OrderState] {
        self.supplies(in: city)
            .map { (name: $0.0.displayName, qty: $0.1, price: self.price(for: $0.0, in: city)) }
            .sorted(by: { $0.price < $1.price })
            .map { .init(product: $0.name, description: "\($0.qty) @ \($0.price.display)") }
    }

    private func sellNow(in city: City) -> [CityDetailState.OrderState] {
        self.demands(in: city)
            .map { (name: $0.0.displayName, qty: $0.1, price: self.price(for: $0.0, in: city)) }
            .sorted(by: { $0.price < $1.price })
            .map { .init(product: $0.name, description: "\($0.qty) @ \($0.price.display)") }
    }
}
