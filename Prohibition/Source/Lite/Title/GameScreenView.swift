//
//  GameScreenView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/20/20.
//

import ComposableArchitecture
import SwiftUI

struct GameScreenView: View {
    let appStore: Store<LiteState, LiteAction>

    @State var buyQty: Int = 1
    @State var sellQty: Int = 1

    var body: some View {
        WithViewStore(self.appStore.scope(state: \.gameState)) { store in
            VStack(alignment: .center, spacing: 8) {
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

                Text(store.state.playerLocation)
                    .bold()

                VStack(alignment: .center) {
                    self.buySegment(state: store.state) { store.send($0) }
                    self.sellSegment(state: store.state) { store.send($0) }
                }
                .padding(8)

                self.cityList(cities: store.cities) { store.send($0) }
                    .padding(8)

                Spacer()
            }
            .padding(8)
        }
    }

    private func sellSegment(state: GameState, send: @escaping ((LiteAction) -> Void)) -> some View {
        HStack {
            Image(systemName: "dollarsign.circle")

            Text("$\(state.current.totalSellPrice(for: self.sellQty))")

            // qty
            Stepper("", value: self.$sellQty, in: 1...9)

            // button
            Button("Sell \(self.sellQty)") {
                send(.play(.sell(units: self.sellQty, total: state.current.totalSellPrice(for: self.sellQty))))
            }
            .disabled(state.isSellDisabled(for: self.sellQty))
        }
    }

    private func buySegment(state: GameState, send: @escaping ((LiteAction) -> Void)) -> some View {
        HStack {
            Image(systemName: "cart.badge.plus")

            // demand
            Text("$\(state.current.totalBuyPrice(for: self.buyQty))")

            // qty
            Stepper("", value: self.$buyQty, in: 1...9)

            // button
            Button("Buy \(self.buyQty)") {
                send(.play(.buy(units: self.buyQty, total: state.current.totalBuyPrice(for: self.buyQty))))
            }
            .disabled(state.isBuyDisabled(for: self.buyQty))
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

struct GameState: Equatable {
    struct CityState: Equatable, Identifiable {
        var id: City { self.city }
        let city: City
        let name: String
        let stock: Int

        var sell: MarketPrice { .sellPrice(for: self.stock) }
        var buy: MarketPrice { .buyPrice(for: self.stock) }

        func totalSellPrice(for qty: Int) -> Int {
            var total = 0
            var item = 0

            while item < qty {
                item += 1
                total += MarketPrice.sellPrice(for: self.stock + item).rawValue
            }

            return total
        }

        func totalBuyPrice(for qty: Int) -> Int {
            var total = 0
            var item = 0

            while item < min(qty, self.stock) {
                item += 1
                total += MarketPrice.buyPrice(for: self.stock - item).rawValue
            }

            return total
        }

        var travelAction: PlayerAction { .travel(self.city) }

        var isStockEmpty: Bool { self.stock < 1 }
    }

    let cities: [CityState]
    let current: CityState
    let playerWallet: Wallet

    let turnsRemaining: String
    let playerMoney: String
    let playerStock: String
    let playerLocation: String

    func isBuyDisabled(for qty: Int) -> Bool {
        self.current.totalBuyPrice(for: qty) > self.playerWallet.money || self.current.stock < qty || qty == 0
    }

    func isSellDisabled(for qty: Int) -> Bool {
        qty > self.playerWallet.stock || qty == 0
    }
}

extension LiteState {
    func cityState(for city: City) -> GameState.CityState {
        .init(city: city, name: city.name, stock: self.current.wallet(for: city).stock)
    }

    var gameState: GameState {
        .init(cities: self.current.cities.map { self.cityState(for: $0) },
              current: self.cityState(for: self.current.location),
              playerWallet: self.current.player, turnsRemaining: "Weeks remaining \(self.current.turnsLeft)",
              playerMoney: "Funds $\(self.current.player.money)",
              playerStock: "Stock \(self.current.player.stock)",
              playerLocation: "Currently in \(self.current.location.rawValue)")
    }
}
