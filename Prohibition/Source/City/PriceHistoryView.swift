//
//  PriceHistoryView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/2/20.
//

import ComposableArchitecture
import SwiftUI

struct HistoriesState: Equatable {
    struct ProductHistory: Equatable {
        let title: String
        let prices: [Money]
        let max: Money
        let min: Money
    }

    let title: String
    let histories: [ProductHistory]
}

struct PriceHistoryView: View {
    var city: City
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: { $0.priceHistoriesView(for: self.city) })) { state in
            List(state.histories, id: \.title) { history in
                VStack(alignment: .leading) {
                    Text(history.title)
                        .font(.caption)
                        .bold()

                    HStack {
                        VStack(alignment: .trailing) {
                            Text(history.max.display)
                                .font(.caption)

                            Spacer()

                            Text(history.min.display)
                                .font(.caption)
                        }

                        SparkLineView(config: history.config)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
            }
            .navigationTitle(self.city.name)
        }
    }
}

private extension AppState {
    func priceHistoriesView(for city: City) -> HistoriesState {
        let hist: [(product: Product, prices: [Money])] = self.marketHistory[city]?
            .compactMap { !$0.value.isEmpty ? ($0.key, $0.value.map(\.sell)) : nil } ?? []

        return .init(
            title: city.name,
            histories: hist.map { $0.product.history(prices: $0.prices) }
        )
    }
}

private extension Product {
    func history(prices: [Money]) -> HistoriesState.ProductHistory {
        let range = self.props.quality.range

        return .init(
            title: self.displayName + (prices.last.map { " \($0.display)" } ?? ""),
            prices: prices,
            max: prices.max().map { Swift.max(range.upperBound, $0) } ?? range.upperBound,
            min: prices.min().map { Swift.min(range.lowerBound, $0) } ?? range.lowerBound
        )
    }
}

private extension HistoriesState.ProductHistory {
    var config: SparkLineView.Config {
        .init(min: self.min, max: self.max, prices: self.prices)
    }
}
