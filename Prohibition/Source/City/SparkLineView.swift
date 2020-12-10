//
//  SparkLineView.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/2/20.
//

import SwiftUI

struct SparkLineView: View {
    struct Config {
        static let minXGap: CGFloat = 5
        let min: Money
        let max: Money
        let prices: [Money]

        func points(for size: CGSize) -> [CGPoint] {
            Array(self.prices.suffix(self.pointsWide(size: size)))
                .enumerated()
                .map { self.point(money: $0.element, offset: $0.offset, size: size) }
        }

        private func point(money: Money, offset: Int, size: CGSize) -> CGPoint {
            .init(x: Self.minXGap * CGFloat(offset), y: self.y(money: money, size: size))
        }

        private func pointsWide(size: CGSize) -> Int {
            Int(size.width / 5.0)
        }

        private func y(money: Money, size: CGSize) -> CGFloat {
            (1 - self.normalized(money: money)) * size.height
        }

        private func normalized(money: Money) -> CGFloat {
            CGFloat(money - self.min) / CGFloat(self.max - self.min)
        }
    }

    let config: Config

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: self.config.points(for: geometry.size).first ?? .zero)
                self.config.points(for: geometry.size).forEach { path.addLine(to: $0) }
            }
            .stroke(
                LinearGradient(gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                               startPoint: .init(x: 0.5, y: 0),
                               endPoint: .init(x: 0.5, y: 0.6)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
    }

    static let gradientStart = Color.green
    static let gradientEnd = Color.red

//    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
//    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
}
