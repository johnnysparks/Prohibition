//
//  MarketListView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/27/20.
//

import ComposableArchitecture
import SwiftUI

private struct CityListViewState: Equatable {
    let title = "Cities"
    let cities: [CityDetailState]
}

struct CityListView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.cityListView)) { state in
            NavigationView {
                List(state.cities, id: \.name.hashValue) { city in
                    NavigationLink(destination: CityDetailView(city: city.city, store: self.store)) {
                        self.cell(state: city)
                    }
                }
                .navigationTitle(state.title)
            }
        }
    }

    private func cell(state: CityDetailState) -> some View {
        VStack(alignment: .leading) {
            HStack {
                HStack(alignment: .top) {
                    Text(state.name)
                        .font(.subheadline)
                        .bold()

                    Image(systemName: "person.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .showIf(state.isUserHere)
                }

                Spacer()

                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<state.resourcesCount, id: \.self) { _ in
                        Image(systemName: "flame")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(0)
                    }

                    ForEach(0..<state.tradersCount, id: \.self) { _ in
                        Image(systemName: "hand.raised")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .padding(0)
                    }
                }
                .frame(alignment: .topTrailing)
            }

            Text(state.population)
                .font(.caption)
        }
    }
}

private extension AppState {
    var cityListView: CityListViewState {
        .init(cities: self.cities.map { self.cityDetailState(for: $0) })
    }
}
