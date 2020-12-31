//
//  Market.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import ComposableArchitecture
import CoreGraphics

enum City: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case cincinnati = "Cincinnati"
    case indianapolis = "Indianapolis"
    case louisville = "Louisville"
    case stLouis = "St. Louis"
    case nashville = "Nashville"
    case atlanta = "Atlanta"
    case charlotte = "Charlotte"
    case columbus = "Columbus"
    case pittsburgh = "Pittsburgh"
    case philadelphia = "Philadelphia"
    case newYork = "New York"
    case boston = "Boston"
    case baltimore = "Baltimore"
    case cleveland = "Cleveland"
    case detroit = "Detroit"
    case chicago = "Chicago"
    case milwaukee = "Milwaukee"
    case jacksonville = "Jacksonville"
    case richmond = "Richmond"
    case knoxvile = "Knoxvile"
    case losAngeles = "Los Angeles"
    case sanFrancisco = "San Francisco"
    case oakland = "Oakland"

    enum Size {
        case town // under 200k
        case city // under 400k
        case majorCity // under 600k
        case metropolis // Under 2M
        case megalopolis // over 2M

        static func from(population: Int) -> Self {
            switch population {
            case ..<200_000:
                return .town
            case 200_000..<400_000:
                return .city
            case 400_000..<600_000:
                return .majorCity
            case 600_000..<2_000_000:
                return .metropolis
            case 2_000_000...:
                return .megalopolis
            default:
                return .town
            }
        }

        var citizens: Int {
            switch self {
            case .town: return 2
            case .city: return 3
            case .majorCity: return 5
            case .metropolis: return 8
            case .megalopolis: return 13
            }
        }
    }

    // TODO: Maybe drop
    enum GrowthRate {
        case decline // - 10%
        case steady  // no change
        case growing // + 10%
        case booming // + 20%
        case exploding // + 45%

        var resourceAvailabilityBonus: Float {
            switch self {
            case .decline:
                return -0.1
            case .steady:
                return 0.0
            case .growing:
                return 0.05
            case .booming:
                return 0.1
            case .exploding:
                return 0.15
            }
        }
    }

    var name: String { self.rawValue }
    var size: Size { Size.from(population: self.props.population) }

    var props: (population: Int, growth: GrowthRate) {
        switch self {
        case .newYork: return (5_620_048, .growing)
        case .chicago: return (2_701_705, .growing)

        case .philadelphia: return (1_823_779, .growing)
        case .detroit: return (993_078, .booming)
        case .cleveland: return (796_841, .booming)
        case .boston: return (748_060, .growing)
        case .baltimore: return (733_826, .growing)

        case .pittsburgh: return (588_343, .growing)
        case .losAngeles: return (576_673, .exploding)
        case .sanFrancisco: return (506_676, .exploding)
        case .milwaukee: return (457_147, .growing)
        case .cincinnati: return (401_247, .booming)
        case .indianapolis: return (314_194, .steady)
        case .stLouis: return (293_792, .steady)
        case .columbus: return (237_000, .booming)
        case .louisville: return (234_900, .steady)
        case .oakland: return (216_261, .booming)
        case .atlanta: return (200_616, .steady)

        case .richmond: return (171_667, .growing)
        case .nashville: return (118_000, .steady)
        case .knoxvile: return (77_818, .steady)
        case .charlotte: return (46_000, .growing)
        case .jacksonville: return (91_558, .steady)
        }
    }

    var gps: CGPoint {
        switch self {
        case .newYork: return .init(x: -73.935242, y: 40.730610)
        case .chicago: return .init(x: -87.623177, y: 41.881832)
        case .philadelphia: return .init(x: -75.165222, y: 39.952583)
        case .detroit: return .init(x: -83.045753, y: 42.331429)
        case .cleveland: return .init(x: -81.681290, y: 41.505493)
        case .boston: return .init(x: -71.057083, y: 42.361145)
        case .baltimore: return .init(x: -76.609383, y: 39.299236)
        case .pittsburgh: return .init(x: -79.995888, y: 40.440624)
        case .losAngeles: return .init(x: -118.243683, y: 34.052235)
        case .sanFrancisco: return .init(x: -122.431297, y: 37.773972)
        case .milwaukee: return .init(x: -87.906471, y: 43.038902)
        case .cincinnati: return .init(x: -84.512016, y: 39.103119)
        case .indianapolis: return .init(x: -86.148003, y: 39.791000)
        case .stLouis: return .init(x: -90.199402, y: 38.627003)
        case .columbus: return .init(x: -82.983330, y: 39.983334)
        case .louisville: return .init(x: -85.764771, y: 38.328732)
        case .oakland: return .init(x: -122.271111, y: 37.804363)
        case .atlanta: return .init(x: -84.386330, y: 33.753746)
        case .richmond: return .init(x: -77.434769, y: 37.541290)
        case .nashville: return .init(x: -86.767960, y: 36.174465)
        case .knoxvile: return .init(x: -83.926453, y: 35.964668)
        case .charlotte: return .init(x: -80.843124, y: 35.227085)
        case .jacksonville: return .init(x: -81.655647, y: 30.332184)
        }
    }
}

extension City: RandomExample {
    static func random() -> City { Self.allCases.randomElement() ?? .nashville }
}
