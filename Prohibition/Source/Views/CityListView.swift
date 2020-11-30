//
//  MarketListView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/27/20.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct CityListView: View {
    struct ViewState: Equatable {
        let title = "Cities"
        let cities: [CityState]

        struct CityState: Equatable {
            struct OrderState: Equatable, Hashable {
                let product: String
                let description: String
            }

            let name: String
            let population: String
            let resourceCount: String
            let traderCount: String
            let sellOrders: [OrderState]
            let buyOrders: [OrderState]
        }
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.cityListView)) { state in
            NavigationView {
                List(state.cities, id: \.name.hashValue) { city in
                    NavigationLink(destination: CityDetailsView(state: city)) {
                        CityCellView(state: city)
                    }
                }
                .navigationTitle(state.title)
            }
        }
    }

    struct CityCellView: View {
        var state: ViewState.CityState

        var body: some View {
            VStack(alignment: .leading) {
                Text(self.state.name)
                    .font(.subheadline)
                    .bold()

                Text(self.state.population)
                    .font(.caption)
            }
        }
    }

    struct CityDetailsView: View {
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

        private let gridLayout: [GridItem] = (0..<3).map { _ in .init(.flexible()) }
        var state: ViewState.CityState

        var body: some View {
            VStack(alignment: .leading) {

                VStack(alignment: .center) {
                    HStack {
                        Image(systemName: "person.3")
                        Text(self.state.population)
                    }
                    HStack {
                        Image(systemName: "hand.raised")
                        Text(self.state.traderCount)
                    }

                    HStack {
                        Image(systemName: "flame")
                        Text(self.state.resourceCount)
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
                        ForEach(self.tradeStyle == .sell ? self.state.sellOrders : self.state.buyOrders, id: \.hashValue) { order in
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
            .navigationTitle(self.state.name)
        }
    }
}

private extension AppState {
    var cityListView: CityListView.ViewState {
        .init(cities: self.cities.map { self.cityView($0) })
    }

    func cityView(_ city: City) -> CityListView.ViewState.CityState {
        .init(name: city.name,
              population: "pop. \(city.props.population)",
              resourceCount: "\(self.locations[city, default: []].filter(\.isResource).count) resources",
              traderCount: "\(self.locations[city, default: []].filter(\.isCitizen).count) buyers/sellers",
              sellOrders: self.sellOrders(in: city),
              buyOrders: self.buyOrders(in: city))
    }

    func sellOrders(in city: City) -> [CityListView.ViewState.CityState.OrderState] {
        self.supplies(in: city).map {
            .init(product: $0.0.displayName,
                  description: "\($0.1) @ \(self.price(for: $0.0, in: city).display)")
        }
    }

    func buyOrders(in city: City) -> [CityListView.ViewState.CityState.OrderState] {
        self.demands(in: city).map {
            .init(product: $0.0.displayName,  description: "\($0.1) @ \(self.price(for: $0.0, in: city).display)")
        }
    }
}

