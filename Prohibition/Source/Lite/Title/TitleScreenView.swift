//
//  TitleScreenView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/20/20.
//

import ComposableArchitecture
import SwiftUI

struct TitleScreenView: View {
    let appStore: Store<LiteState, LiteAction>

    var body: some View {
        WithViewStore(self.appStore) { store in
            VStack(alignment: .center, spacing: 100) {
                Text("Pocket Prohibition")
                    .bold()
                    .font(.largeTitle)
                    .lineLimit(0)

                HStack(spacing: 48.0) {
                    Button("New Game") {
                        store.send(.game(.newGame))
                    }

                    Button("Load Game") {
                        store.send(.game(.loadGame))
                    }
                    .disabled(store.noSaveGame)
                }
            }
            .padding(24)
        }
    }
}

private extension LiteState {
    var noSaveGame: Bool { self.last == nil }
}
