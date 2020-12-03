//
//  PlayerDetailView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/2/20.
//

import ComposableArchitecture
import SwiftUI

struct PlayerDetailState: Equatable {
    let title = "You"
    let location: String
    let money: String
    let inventories: [InventoryViewState]
}

struct InventoryViewState: Equatable, Identifiable {
    var id: Product { self.product }

    let product: Product
    let title: String
    let details: String
}

struct PlayerDetailView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.playerDetailState)) { state in
            NavigationView {
                VStack {
                    Text("Your stuff:")
                        .font(.title)

                    Text(state.money)

                    List(state.inventories, id: \.id) { inventory in
                        VStack {
                            Text(inventory.title)
                            Text(inventory.details)
                        }
                    }.navigationTitle(state.title)
                }
            }
        }
    }
}

private extension AppState {
    var money: Money { self.capital[self.user] ?? 0 }
    var playerDetailState: PlayerDetailState {
        .init(location: self.userCity?.name ?? "Nowhere",
              money: self.money.display,
              inventories: (self.inventories[self.user] ?? []).map(\.viewState))
    }
}

private extension Inventory {
    var viewState: InventoryViewState {
        .init(product: self.product,
              title: self.product.displayName,
              details: "\(self.quantity) units" + (self.brand.map { " by \($0)" } ?? ""))
    }
}
