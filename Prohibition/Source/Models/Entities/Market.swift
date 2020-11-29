//
//  Market.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

import Foundation
import ComposableArchitecture
import CoreData


enum City: String, CaseIterable {
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

        /// 1 = all available, 0.1 = ~10% available
        var resourceAvailability: Float {
            switch self {
            case .town:
                return 0.05
            case .city:
                return 0.1
            case .majorCity:
                return 0.2
            case .metropolis:
                return 0.3
            case .megalopolis:
                return 0.5
            }
        }
    }

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
}

extension City: RandomExample {
    static func random() -> City { Self.allCases.randomElement() ?? .nashville }
}

extension Money {
    enum Category: Equatable {
        case cheap
        case affordable
        case midrange
        case expensive
        case exorbitant

        var randomPrice: Money { .random(in: self.range) }

        var range: ClosedRange<Money> {
            switch self {
            case .cheap:
                return 1...2_00
            case .affordable:
                return 0_75...5_00
            case .midrange:
                return 5_00...50_00
            case .expensive:
                return 50_00...100_00
            case .exorbitant:
                return 100_00...10_000_00
            }
        }
    }
}

extension Product.Category {
    func randomQuantity() -> Int {
        switch self {
        case .ingredient:
            return Int.random(in: 1...19)
        case .consumable:
            return Int.random(in: 1...9)
        case .equipmentParts:
            return Int.random(in: 1...7)
        case .lightEquipment:
            return Int.random(in: 1...2)
        case .heavyEquipment:
            return Int.random(in: 1...2)
        }
    }

    static func randomStarterCitizenDemand() -> Product.Category {
        switch Int.random(in: 0...100) {
        case 0..<60:
            return .consumable
        case 60..<70:
            return .ingredient
        case 70..<80:
            return .equipmentParts
        case 80..<90:
            return .lightEquipment
        case 90...:
            return .heavyEquipment
        default:
            return .ingredient
        }
    }

    static func randomStarterResource() -> Product.Category {
        switch Int.random(in: 0...100) {
        case 0..<70:
            return .ingredient
        case 70..<85:
            return .consumable
        case 85..<92:
            return .equipmentParts
        case 92..<97:
            return .lightEquipment
        case 97...:
            return .heavyEquipment
        default:
            return .ingredient
        }
    }
}

extension Product {
    var priceCategory: Money.Category {
        switch self.category {
        case .ingredient:
            return .cheap
        case .consumable:
            return .affordable
        case .equipmentParts:
            return .midrange
        case .lightEquipment:
            return .expensive
        case .heavyEquipment:
            return .exorbitant
        }
    }

    var randomBrand: Brand? {
        switch self.category {
        case .ingredient, .equipmentParts, .lightEquipment:
            return nil
        case .consumable, .heavyEquipment:
            return Brand.random()
        }
    }

    var supply: Market.Elasticity {
        switch self.category {
        case .ingredient:
            return Bool.random() ? .inelastic : .low
        case .consumable:
            return .low
        case .equipmentParts, .lightEquipment, .heavyEquipment:
            return .high
        }
    }

    var demand: Market.Elasticity {
        switch self.category {
        case .ingredient:
            return Bool.random() ? .inelastic : .inelastic
        case .consumable:
            return .low
        case .equipmentParts, .lightEquipment, .heavyEquipment:
            return .high
        }
    }
}

extension Market {
    enum Elasticity {
        // Demand is "unit elastic" at the quantity where marginal revenue is zero, and inelastic at negative margins
        // Supply is inelastic when consumption does not depend on price. Alcoholics pay any price for booze, and nobody will buy tin cans if a buckets are super cheap and completely replace the need for cans.
        case inelastic
        // Price has little impact on supply/demand (constant resource production, good is a need)
        case low
        // Luxury resources
        case high
    }
}

struct Market: Equatable {
    // Supply of goods generated by this city
    let city: City
    let basePrices: [Product: Money]
    let traders: [Trader]

    var citizens: [Trader] { self.traders.filter(\.entity.isCitizen) }
    var resources: [Trader] { self.traders.filter(\.entity.isResource) }

    init(city: City) {
        self.city = city
        self.basePrices = Product.allCases.reduce(into: [:]) { $0[$1] = $1.priceCategory.randomPrice }
        let resources: [Trader] = (0..<city.size.resources).map { _ in Trader.randomResource() }
        let citizens: [Trader] = (0..<city.size.citizens).map { _ in Trader.randomCitizen() }
        self.traders = resources + citizens
    }

    func price(for product: Product) -> Money {
        // price is determined by total available inventory and total demand
        // each market has a "unit price" per product where units of supply == units of demand
        // the maximum supply for any resource == 99
        // the minimum supply for any resource == 0
        // the affordability of each item determines the top and bottom price when demand >>> supply or vice versa

        let (supply, demand) = self.supplyAndDemand(for: product)
        let basePrice = self.basePrices[product] ?? product.priceCategory.randomPrice
        let priceRange = product.priceCategory.range
        let priceSpread = Float(priceRange.upperBound - priceRange.lowerBound)

        // supply = demand = unit. 100 demand - 0 supply = max shift. 0 demand - 100 supply = minimized price
        let fractionalMarketBalance = Float(demand - supply) / 100.0

        // center the price range of the category on the base price and shift it by the fractional market balance amount.
        // (multiply the fractionalMarketBalance against the price range and add it to the base price)
        return basePrice + Int(fractionalMarketBalance * priceSpread)
    }

    static let all = City.allCases.map(Market.init(city:))

    private func supplyAndDemand(for product: Product) -> (supply: Int, demand: Int) {
        self.traders.reduce((0, 0)) { res, trader in
            let totals = trader.inventories.supplyAndDemand(for: product)
            return (res.0 + totals.0, res.1 + totals.1)
        }
    }

    var supplies: [(Product, Int)] { self.traders.flatMap(\.inventories).supplies }

    var demands: [(Product, Int)] { self.traders.flatMap(\.inventories).demands }
}

extension Market: RandomExample {
    static func random() -> Self { .init(city: .random()) }
}

private extension Array where Element == Inventory {
    func supplyAndDemand(for product: Product) -> (supply: Int, demand: Int) {
        self.reduce((0, 0)) { $1.product == product ? ($0.0 + $1.supply, $0.1 + $1.demand) : (0, 0) }
    }

    var supplies: [(Product, Int)] {
        self.reduce(into: [Product: Int]()) { $0[$1.product] = ($0[$1.product] ?? 0) + $1.supply }
            .map { ($0.key, $0.value) }
            .filter { $1 > 0 }
    }

    var demands: [(Product, Int)] {
        self.reduce(into: [Product: Int]()) { $0[$1.product] = ($0[$1.product] ?? 0) + $1.demand }
            .map { ($0.key, $0.value) }
            .filter { $1 > 0 }
    }
}

extension City.Size {
    var citizens: Int {
        switch self {
        case .town: return 1
        case .city: return 2
        case .majorCity: return 3
        case .metropolis: return 5
        case .megalopolis: return 7
        }
    }

    var resources: Int {
        switch self {
        case .town: return 1
        case .city: return 1
        case .majorCity: return 2
        case .metropolis: return 3
        case .megalopolis: return 5
        }
    }
}

extension Trader {
    static func randomResource() -> Trader {
        // Not likely to want existing stuff much
        let supplies: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterResource()) }
            .map { .init(product: $0, brand: $0.randomBrand, supply: $0.category.randomQuantity(), demand: 0)}

        return Trader(entity: .randomResource(),
                      inventories: supplies,
                      capital: .random(),
                      personality: .random())
    }

    static func randomCitizen() -> Trader {
        let demands: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterCitizenDemand()) }
            .map { .init(product: $0, brand: $0.randomBrand, supply: 0, demand: $0.category.randomQuantity()) }

        let supplies: [Inventory] = (0..<3)
            .map { _ in Product.random(in: .randomStarterResource()) }
            .map { .init(product: $0, brand: $0.randomBrand, supply: $0.category.randomQuantity(), demand: 0)}

        return Trader(entity: .randomCitizen(),
                      inventories: demands + supplies,
                      capital: .random(),
                      personality: .random())
    }
}
