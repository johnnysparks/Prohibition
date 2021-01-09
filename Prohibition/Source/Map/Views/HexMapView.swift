//
//  HexMapView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/3/21.
//

import ComposableArchitecture
import Foundation
import SwiftUI

class CityUpdates: ObservableObject {
    @Published var city: City

    init(city: City) {
        self.city = city
    }
}

struct HexMapView: View {
    @State var focus = HexGrid.Cell(q: -573, r: 574)
    @ObservedObject var updates = CityUpdates(city: .atlanta)

    private let grid = HexGrid(size: 17, orientation: .pointy)
    private let map: HexMapData

    init(map: HexMapData, city: City) {
        self.map = map
        self.updates.city = city
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                Group {
                    ForEach(self.map.states) { state in
                        Path(state.path)
                            .fill(Color.green)
                    }

                    ForEach(self.map.cities) { state in
                        Path(state.path)
                            .fill(Color.red)
                    }

                    ForEach(self.map.annotations, id: \.label) { annotation in
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
            .onReceive(self.updates.$city) { city in
                self.focus(city: city)
            }
        }
    }

    private func focus(city: City) {
        guard let focus = self.map.cities.first(where: { $0.description == city.name })?.focus else {
            return
        }

        self.focus = focus
    }

    private func region(size: CGSize) -> HexGrid.Region {
        .init(grid: self.map.grid, focus: self.focus, scale: 0.3, screen: size)
    }

    private func handleTouch(at point: CGPoint, in size: CGSize) {
        let focusCell = self.region(size: size).cell(from: point)
        let matches = self.map.states.filter { $0.cells.contains(focusCell) }

        if !matches.isEmpty, let hitFocus = matches.first?.focus {
            self.focus = hitFocus
        }
    }
}
