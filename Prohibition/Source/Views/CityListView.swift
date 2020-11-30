//
//  MarketListView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/27/20.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct CityListViewState: Equatable {
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
                Text(state.name)
                    .font(.subheadline)
                    .bold()

                Image(systemName: "person.circle")
                    .font(.caption)
                    .foregroundColor(Color.green)
                    .showIf(state.isUserHere)
            }

            Text(state.population)
                .font(.caption)
        }
    }

}

extension AppState {
    var cityListView: CityListViewState {
        .init(cities: self.cities.map { self.cityDetailState(for: $0) })
    }
}

