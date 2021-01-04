//
//  HexMapView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/3/21.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct HexMapView: View {
    @State var focus: HexGrid.Cell
    private let grid = HexGrid(size: 17, orientation: .pointy)
    private let data: HexMapData

    init(city: City) {
        let data = HexMapData(grid: self.grid)
        self.data = data
        _focus = State(initialValue: data.cities.first(where: { $0.description == city.name })!.focus)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                Group {
                    ForEach(self.data.states) { state in
                        Path(state.path)
                            .fill(Color.green)
                    }

                    ForEach(self.data.cities) { state in
                        Path(state.path)
                            .fill(Color.red)
                    }

                    ForEach(self.data.annotations, id: \.label) { annotation in
                        Text(annotation.label)
                            .font(.system(size: 40))
                            .offset(annotation.anchor.size)
                            .foregroundColor(.white)
                    }
                }
                .offset(self.region(size: geo.size).offset)
                .scaleEffect(self.region(size: geo.size).scale, anchor: .topLeading)
                .animation(.spring())
            }
            .background(Color.black)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ self.handleTouch(at: $0.startLocation, in: geo.size) })
            )
        }
    }

    private func region(size: CGSize) -> HexGrid.Region {
        .init(grid: self.grid, focus: self.focus, scale: 0.3, screen: size)
    }

    private func handleTouch(at point: CGPoint, in size: CGSize) {
        let focusCell = self.region(size: size).cell(from: point)
        let matches = self.data.states.filter { $0.cells.contains(focusCell) }

        if !matches.isEmpty, let hitFocus = matches.first?.focus {
            self.focus = hitFocus
        }
    }
}
