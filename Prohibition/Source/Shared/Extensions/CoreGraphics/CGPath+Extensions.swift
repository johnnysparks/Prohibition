//
//  CGPath+Extensions.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import CoreGraphics
import Foundation

extension Array where Element == CGPath {
    var union: CGPath {
        let p = CGMutablePath()
        self.forEach { p.addPath($0) }
        return p as CGPath
    }
}
