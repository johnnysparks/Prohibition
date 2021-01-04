//
//  MapApp.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/22/20.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct CityListMapView: View {
    let appStore: Store<LiteState, LiteAction>

    var body: some View {
        WithViewStore(self.appStore.scope(state: \.gameState)) { store in
            VStack(alignment: .center, spacing: 8) {
                HexMapView(city: store.current.city)
                    .frame(maxWidth: .infinity, idealHeight: 200)
                    .clipped()

                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(store.state.playerMoney)
                        Text(store.state.playerStock)
                    }

                    Spacer()

                    Text(store.state.turnsRemaining)
                }
                .frame(maxWidth: .infinity)
                .padding(8)

                self.cityList(cities: store.cities) { store.send($0) }
                    .padding(8)

                Spacer()
            }
            .padding(8)
        }
    }

    private func cityList(cities: [GameState.CityState], send: @escaping ((LiteAction) -> Void)) -> some View {
        VStack(alignment: .leading) {
            ForEach(cities) { city in
                HStack {
                    Text(city.name)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "cart.badge.plus")
                        .font(.caption)

                    Text(city.buy.display)
                        .foregroundColor(city.buy.buyColor)
                        .frame(width: 30)

                    Image(systemName: "dollarsign.circle")
                        .font(.caption)

                    Text(city.sell.display)
                        .foregroundColor(city.sell.sellColor)
                        .frame(width: 30)

                    // button
                    Button("Go") {
                        send(.play(.travel(city.city)))
                    }
                }
            }
        }
    }
}

struct MapApp: App {
    var body: some Scene {
        WindowGroup {
//            CityListMapView(appStore: <#Store<LiteState, LiteAction>#>)
        }
    }
}
