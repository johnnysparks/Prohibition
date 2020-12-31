//
//  MapView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/19/20.
//

import ComposableArchitecture
import SwiftUI

struct MapDataView: View {
    var hexSize: Binding<CGFloat>

    let cities: [City] = [.stLouis, .nashville, .atlanta, .columbus, .pittsburgh, .philadelphia, .newYork]

//    let cities: [City] = [.sanFrancisco, .losAngeles]
//    let cities: [City] = []

    let screenSize: CGSize

    init(screenSize: CGSize, hexSize: Binding<CGFloat>) {
        self.screenSize = screenSize
        self.hexSize = hexSize
    }

    var body: some View {
        let hexGrid = HexGrid(size: self.hexSize.wrappedValue, orientation: .pointy)
        let borderData = BorderData(stateCollection: .eastern, hexGrid: hexGrid)
        let renderer = MapRenderer(screenSize: self.screenSize,
                                   hexGrid: hexGrid,
                                   border: borderData,
                                   cities: self.cities)

        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            BordersView(mapRenderer: renderer)

            ForEach(renderer.cities) { city in
                CityView(mapRenderer: renderer, city: city)
            }

            Text("\(self.hexSize.wrappedValue)")
                .foregroundColor(.white)
        }
    }

    struct BordersView: View {
        let mapRenderer: MapRenderer

        var body: some View {
            ZStack {
                ForEach(self.mapPaths, id: \.self) { path in
                    path
                        .fill(Color.green)
                        .opacity(0.25)
                }

                ForEach(self.mapPaths, id: \.self) { path in
                    path
                        .stroke(lineWidth: 1)
                        .foregroundColor(.black)
                }
            }
        }

        var mapPaths: [Path] {
            self.mapRenderer.borders.map { line in
                var path = Path()
                path.move(to: line.points[0])
                for point in line.points {
                    path.addLine(to: point)
                }

                return path
            }
        }

        var debugMapPath: Path {
            var path = Path()
            for line in self.mapRenderer.debugBorders.map(\.points) {
                for point in line {
                    path.addEllipse(in: .init(x: point.x, y: point.y, width: 1, height: 1))
                }
            }

            return path
        }
    }

    struct CityView: View {
        let mapRenderer: MapRenderer
        let city: MapElement

        var center: CGPoint { self.city.points.first ?? .zero }

        var cityPath: Path {
            var path = Path()
            path.move(to: self.city.points[0])
            for point in self.city.points {
                path.addLine(to: point)
            }

            return path
        }

        var body: some View {
            self.cityPath
                .foregroundColor(.red)

            Text(city.text)
                .foregroundColor(.red)
                .background(Color.black)
                .font(.caption)
                .offset(x: self.center.x, y: self.center.y)
                .alignmentGuide(.leading) { d in d[.leading] + d.width / 2 }
        }
    }
}

struct MapView: View {
    @State var hexSize: CGFloat = 0.157586

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    MapDataView(screenSize: geo.size, hexSize: self.$hexSize)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .background(Color.black)
                }

                Slider(value: self.$hexSize, in: 0.14...0.18)
            }
        }
    }
}

extension Path: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.cgPath)
    }
}
