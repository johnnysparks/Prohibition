//
//  EventLogDetailView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/6/20.
//

import ComposableArchitecture
import SwiftUI

struct EventLogDetailView: View {
    let state: EventLogEntryState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: state.icon)

                Text(state.title)
                    .font(.subheadline)
                    .lineLimit(0)
            }
            .padding(8)

            Text(state.detail)
                .lineLimit(0)
                .padding(8)

            List(state.itemized, id: \.hashValue) { entry in
                Text(entry)
                    .font(.caption)
                    .lineLimit(0)
            }
        }
        .navigationTitle(state.name)
    }
}
