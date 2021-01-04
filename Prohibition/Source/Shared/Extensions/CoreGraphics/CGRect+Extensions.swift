//
//  CGRect+Extensions.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import CoreGraphics
import Foundation

extension CGRect {
    var area: CGFloat {
        self.height * self.width
    }

    var isDrawable: Bool {
        self.area > 0 && self.area < 99999999
    }

    var midPoint: CGPoint { .init(x: self.midX, y: self.midY) }
}
