//
//  CGSize+Extensions.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import CoreGraphics
import Foundation

extension CGSize {
    var point: CGPoint { .init(x: self.width, y: self.height) }
    var half: CGSize { .init(width: self.width * 0.5, height: self.height * 0.5) }
    var inverted: CGSize { .init(width: -self.width, height: -self.height) }
}
