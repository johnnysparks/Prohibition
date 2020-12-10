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

    struct IconState: Equatable, Hashable {
        let id: String
        let name: String
    }

    let name: String
    let city: City
    let population: String
    let isUserHere: Bool

    let details: String

    let supplyCount: Int
    let demandCount: Int
    let sellNow: [OrderState]
    let buyNow: [OrderState]
    let travel: Travel?
    let icons: [IconState]
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
                        Text(state.details)
                    }

                    NavigationLink(destination: PriceHistoryView(city: self.city, store: self.store)) {
                        Text("Price Histories")
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
        let suppliers: [CityDetailState.IconState] = self.inventories[city]?
            .filter { $0.value.contains(where: \.isSupply) }
            .map { .init(id: $0.key.id.uuidString + "flame", name: "flame") } ?? []

        let demanders: [CityDetailState.IconState] = self.inventories[city]?
            .filter { $0.value.contains(where: \.isDemand) }
            .map { .init(id: $0.key.id.uuidString + "hand.raised", name: "hand.raised") } ?? []

        return .init(name: city.name,
              city: city,
              population: "pop. \(city.props.population)",
              isUserHere: self.userCity == city,
              details: "\(suppliers.count) resources \(demanders.count) buyers/sellers",
              supplyCount: suppliers.count,
              demandCount: demanders.count,
              sellNow: self.sellNow(in: city),
              buyNow: self.buyNow(in: city),
              travel: self.userCity.map { Travel(entity: self.user, start: $0, end: city) },
              icons: suppliers + demanders
        )
    }

    private func buyNow(in city: City) -> [CityDetailState.OrderState] {
        (self.marketHistory[city]?.values.compactMap(\.last) ?? [])
            .filter(\.hasSupply)
            .compactMap(\.buyOrder)
    }

    private func sellNow(in city: City) -> [CityDetailState.OrderState] {
        (self.marketHistory[city]?.values.compactMap(\.last) ?? [])
            .filter(\.hasDemand)
            .compactMap(\.sellOrder)
    }
}

private extension MarketSummary {
    var sellOrder: CityDetailState.OrderState? {
        .init(product: self.product.displayName, description: "\(self.demandQty) @ \(self.sell.display)")
    }

    var buyOrder: CityDetailState.OrderState? {
        .init(product: self.product.displayName, description: "\(self.supplyQty) @ \(self.buy.display)")
    }
}
