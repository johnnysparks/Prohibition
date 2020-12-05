//
//  EntityListView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/2/20.
//

import ComposableArchitecture
import SwiftUI

private struct EntityListViewState: Equatable {
    let title = "Citizens"
    let entities: [EntityDetailState]
}

private struct EntityDetailState: Equatable, Identifiable {
    var id: Entity { self.entity }
    let entity: Entity

    let name: String
    let icon: String
    let color: Color
    let inventory: String
    let money: String
}

struct EntityListView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store.scope(state: \.entityListView)) { state in
            NavigationView {
                List(state.entities, id: \.entity.id) { entity in
                    self.cell(state: entity)
                }
                .navigationTitle(state.title)
            }
        }
    }

    private func cell(state: EntityDetailState) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: state.icon)
                    .foregroundColor(state.color)
                    .font(.caption)

                Text(state.name)
                    .font(.subheadline)

                Spacer()

                Text(state.money)
                    .font(.subheadline)
            }

            Text(state.inventory)
                .font(.footnote)
        }
    }
}

private let kColors: [Color] = [.red, .green, .blue, .orange, .pink, .purple]

private extension AppState {
    var entityListView: EntityListViewState {
        .init(entities: self.entities.filter(\.isCitizen).compactMap { self.entityDetailState(for: $0) })
    }

    func entityDetailState(for entity: Entity) -> EntityDetailState? {
        guard let city = self.locations[entity], let inventories = self.inventories[city]?[entity] else {
            return nil
        }

        let dict: [Product: Int] = inventories
            .filter(\.isSupply)
            .reduce(into: [:]) { $0[$1.product] = ($0[$1.product] ?? 0) + $1.quantity }

        let (unique, total) = (dict.keys.count, dict.values.reduce(0, +))

        return .init(
            entity: entity,
            name: "\(entity.displayName) from \(city.name)",
            icon: "person.fill",
            color: kColors[abs(entity.displayName.hash) % kColors.count],
            inventory: "\(unique) products, \(total) total items",
            money: (self.capital[entity] ?? 0).display)
    }
}
