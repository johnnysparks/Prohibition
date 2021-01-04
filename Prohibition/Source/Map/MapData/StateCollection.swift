//
//  StateCollection.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 1/2/21.
//

import Foundation

enum StateCollection {
    case continuous
    case california
    case jersey
    case rhodeIsland
    case westCoast
    case newYork
    case all
    case gulf
    case eastern
    case midwest

    func includes(stateName: String) -> Bool {
        switch self {
        case .continuous:
            return !["Alaska", "Hawaii", "Puerto Rico"].contains(stateName)
        case .all:
            return true
        case .jersey:
            return stateName == "New Jersey"
        case .california:
            return stateName == "California"
        case .newYork:
            return stateName == "New York"
        case .rhodeIsland:
            return stateName == "Rhode Island"
        case .westCoast:
            return ["Oregon", "Washington", "California"].contains(stateName)
        case .gulf:
            return ["Texas", "Florida", "Alabama", "Louisiana", "Mississippi"].contains(stateName)
        case .eastern:
            return ![
                "Oregon", "Washington", "California", "Nevada", "Idaho", "Montana", "Colorado", "Wyoming",
                "Utah", "Arizona", "New Mexico", "Texas", "North Dakota", "South Dakota", "Nebraska",
                "Oklahoma", "Alaska", "Hawaii", "Kansas", "Puerto Rico",
                "Maine", "Minnesota", "Massachusetts", "Vermont", "Rhode Island", "New Hampshire"
            ].contains(stateName)
        case .midwest:
            return ["Wisconsin", "Illinois", "Minnesota", "Iowa"].contains(stateName)
        }
    }
}
