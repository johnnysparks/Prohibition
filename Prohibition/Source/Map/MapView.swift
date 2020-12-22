//
//  MapView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/19/20.
//

import ComposableArchitecture
import SwiftUI

struct Vertex: Equatable {
    var n1: Node
    var n2: Node
}

struct Node: Equatable {
    var x: CGFloat {
        get { self.position.x }
        set { self.position.x = newValue }
    }
    var y: CGFloat {
        get { self.position.y }
        set { self.position.y = newValue }
    }
    var position: CGPoint
    var vertices: [Vertex]

    mutating func link(to node: Node) {
        let vertex = Vertex(n1: self, n2: node)
        if self.vertices.contains(vertex) {
            return
        }

        self.vertices.append(vertex)
    }
}

protocol Mapable {
    // Default
    var home: CGPoint { get }
    var size: CGSize { get }

    /// The default zoom level is 1.
    /// This should show a moderate amount of map at once (~25-50)
    var zoom: CGFloat { get set }
    var zoomRange: Range<CGFloat> { get set }

    var nodes: [Node] { get }
    var vertices: [Vertex] { get }
}

extension Mapable {
    var size: CGSize {
        guard let minX = self.nodes.min(by: { $0.x < $1.x })?.x,
              let minY = self.nodes.min(by: { $0.y < $1.y })?.y,
              let maxX = self.nodes.max(by: { $0.x < $1.x })?.x,
              let maxY = self.nodes.max(by: { $0.y < $1.y })?.y else
        {
            return .zero
        }

        return .init(width: maxX - minX, height: maxY - minY)
    }
}

struct GridMap: Mapable {
    static func generate(size: CGSize) -> GridMap? {
        var _ = CGPoint(x: size.width * -0.5, y: size.height * -0.5)
        return nil
    }

    var zoom: CGFloat = 1

    var zoomRange: Range<CGFloat> = 0.5..<1.5

    var nodes: [Node] = []

    var vertices: [Vertex] = []

    var home: CGPoint = .zero
}

class MapGenerator {
    enum MapType {
        case grid
    }

    init(type: MapType) {}
}

struct MapView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        Text("map")
    }
}
