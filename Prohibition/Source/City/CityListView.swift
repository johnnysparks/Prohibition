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
                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem()], alignment: .center, spacing: 10) {
                        ForEach(state.cities, id: \.name.hashValue) { city in
                            NavigationLink(destination: CityDetailView(city: city.city, store: self.store)) {
                                self.cell(state: city)
                            }
                        }
                    }
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                }
                .navigationTitle(state.title)
            }
        }
    }

    private func cell(state: CityDetailState) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(state.name)
                    .bold()

                Text(state.population)
                    .font(.caption)
            }
            .padding(8)

            Image(systemName: "person.circle")
                .font(.caption)
                .foregroundColor(.blue)
                .showIf(state.isUserHere)
                .padding(16)

            Spacer()

            self.icons(state: state)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .padding(8)
        }
    }

    func icons(state: CityDetailState) -> some View {
        LazyHGrid(rows: .init(repeating: .init(.fixed(8)), count: 3), alignment: .center, spacing: 2) {
            ForEach(state.icons, id: \.id) { icon in
                Image(systemName: icon.name)
                    .font(.caption)
                    .foregroundColor(icon.name == "flame" ? .purple : .green)
                    .padding(0)
                    .frame(minWidth: 8, maxWidth: .infinity)
            }
        }
        .frame(minHeight: 0, maxHeight: 50, alignment: .top)
    }
}

private extension AppState {
    var cityListView: CityListViewState {
        .init(cities: self.cities.map { self.cityDetailState(for: $0) })
    }
}
