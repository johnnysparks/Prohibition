//
//  MarketListView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/27/20.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct MarketListView: View {
    struct ViewState: Equatable {
        let title = "Markets"
        let markets: [MarketViewState]
    }

    struct MarketViewState: Equatable {
        struct Order: Equatable, Hashable {
            let product: String
            let description: String
        }

        let name: String
        let population: String
        let resourceCount: String
        let traderCount: String
        let sellOrders: [Order]
        let buyOrders: [Order]
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.viewState)) { state in
            NavigationView {
                List(state.markets, id: \.name.hashValue) { market in
                    NavigationLink(destination: MarketDetailsView(state: market)) {
                        MarketCellView(state: market)
                    }
                }
                .navigationTitle(state.title)
            }
        }
    }

    struct MarketCellView: View {
        var state: MarketViewState

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

    struct MarketDetailsView: View {
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
        var state: MarketViewState

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

//                Picker(selection: self.$tradeStyle, label: Text("Buy or Sell")) {
//                    ForEach(0..<TradeStyle.allCases.count) { index in
//                        Text(TradeStyle.allCases[index].rawValue).tag(index)
//                    }
//                }.pickerStyle(SegmentedPickerStyle())

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
    var viewState: MarketListView.ViewState {
        .init(markets: Market.all.sorted(by: { $0.city.props.population < $1.city.props.population }).map(\.viewState))
    }
}

private extension Market {
    var viewState: MarketListView.MarketViewState {
        .init(name: self.city.name,
              population: "pop. \(self.city.props.population)",
              resourceCount: "\(self.resources.count) resources",
              traderCount: "\(self.citizens.count) buyers/sellers",
              sellOrders: self.sellOrders,
              buyOrders: self.buyOrders
        )
    }

    var sellOrders: [MarketListView.MarketViewState.Order] {
        self.supplies.map {
            .init(product: $0.0.displayName,
                  description: "\($0.1) @ \(self.price(for: $0.0).display)")
        }
    }

    var buyOrders: [MarketListView.MarketViewState.Order] {
        self.demands.map {
            .init(product: $0.0.displayName,
                  description: "\($0.1) @ \(self.price(for: $0.0).display)")
        }
    }
}

