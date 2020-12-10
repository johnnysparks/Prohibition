//
//  View+Hidden.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/30/20.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }

    @ViewBuilder func showIf(_ shouldShow: Bool) -> some View {
        switch shouldShow {
        case true: self
        case false: self.hidden()
        }
    }
}
