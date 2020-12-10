//
//  Array+Extensions.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/5/20.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        guard let last = self.indices.last, index < last else {
            return nil
        }

        return self[index]
    }
}
