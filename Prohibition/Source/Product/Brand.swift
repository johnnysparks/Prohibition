//
//  Brand.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

enum Brand: String, Equatable, CaseIterable {
    // Beer
    case busch = "Anheuser-Busch"
    case coors = "Coors Brewing Company"
    case miller = "Miller High Life Co"
    case pabst = "Pabst Brewing Company"
    case yuengling = "D.G. Yuengling & Son, Inc"
    case budweiser = "Budweiser"

    // Liquor
    case bacardi = "Bacardi"
    case jimBeam = "Jim Beam"
    case jack = "Jack Daniels"
    case jameson = "Jameson"
    case johnnie = "Johnnie Walker"

    var name: String { self.rawValue }
}

extension Brand: RandomExample {
    static func random() -> Self { self.allCases.randomElement() ?? .busch }
}
