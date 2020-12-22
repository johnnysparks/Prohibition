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
            VStack(alignment: .center, spacing: 16) {
                Text("Pocket Prohibition")

                Text("Game Over")
                    .bold()
                    .font(.largeTitle)

                Spacer()

                Text("High Scores")
                    .bold()
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(store.state.highScoreItems) { score in
                        HStack(alignment: .top) {
                            Text(score.rank)
                                .frame(width: 20)

                            Text(score.money)
                        }
                    }
                }

                Spacer()

                Button("New Game") {
                    store.send(.game(.newGame))
                }
                .padding(16)
            }
            .padding(24)
        }
    }
}

private extension LiteState {
    struct HighScore: Identifiable {
        var id: String { self.rank }
        let rank: String
        let money: String
    }

    var highScoreItems: [HighScore] {
        Array(self.highScores
            .sorted(by: { $0 > $1 })
            .enumerated()
            .map { HighScore(rank: "\($0 + 1)", money: "$\($1)") }
            .prefix(10))
    }
}
