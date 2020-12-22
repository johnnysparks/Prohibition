//
//  GameOverScreenView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/20/20.
//

import ComposableArchitecture
import SwiftUI

struct GameOverScreenView: View {
    let appStore: Store<LiteState, LiteAction>

    var body: some View {
        WithViewStore(self.appStore) { store in
            VStack(alignment: .center, spacing: 100) {
                Text("Pocket Prohibition")

                Text("Game Over")
                    .bold()
                    .font(.largeTitle)
                    .lineLimit(0)

                Text("High Scores")

                Button("New Game") {
                    store.send(.game(.newGame))
                }
            }
            .padding(24)
        }
    }
}
