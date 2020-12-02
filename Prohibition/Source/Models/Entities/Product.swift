//
//  Product.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 11/26/20.
//

enum Product: String, Equatable, CaseIterable {
    enum Category: CaseIterable, Equatable, RandomExample {
        case ingredient
        case consumable
        case equipmentParts
        case equipment

        static func random() -> Product.Category { self.allCases.randomElement() ?? .consumable }
    }

    enum Quality: CaseIterable, Equatable {
        case bulk
        case discount
        case economy
        case budget
        case affordable
        case midrange
        case aboveAverage
        case superior
        case expensive
        case lavish
        case luxury
        case exorbitant

        var randomPrice: Money { .random(in: self.range) }

        var range: ClosedRange<Money> {
            switch self {
            case .bulk:
                return 1...10
            case .discount:
                return 5...15
            case .economy:
                return 10...20
            case .budget:
                return 15...25
            case .affordable:
                return 20...50
            case .midrange:
                return 50...75
            case .aboveAverage:
                return 75...2_00
            case .superior:
                return 2_00...5_00
            case .expensive:
                return 5_00...10_00
            case .lavish:
                return 10_00...50_00
            case .luxury:
                return 50_00...100_00
            case .exorbitant:
                return 100_00...10_000_00
            }
        }
    }

    // Commodity
    case corn = "Corn"
    case yeast = "Yeast"
    case sugar = "Sugar"
    case grapes = "Grapes"
    case malt = "Malt"
    case barley = "Barley"
    case rye = "Rye"
    case juniper = "Juniper"
    case mash = "Mash"
    case potato = "Potatoes"
    case wheat = "Wheat"
    case molasses = "Molasses"

    // Consumer Goods

    // Generic starter
    case wine = "Wine"
    case beer = "Beer"

    // Generic starter liquor
    case hooch = "Hooch"
    case bathtubGin = "Bathtub Gin"
    case moonshine = "Moonshine"

    // Liquor
    case gin = "Gin"
    case bourbon = "Bourbon"
    case rum = "Rum"
    case vodka = "Vodka"
    case brandy = "Brandy"
    case tequila = "Tequila"
    case whiskey = "Whiskey"

    // Fancy Drinks
    case champagne = "Champagne"
    case burgundy = "Burgundy"

    // Equipment

    // Parts
    case parts = "Machine Parts"

    // Grain processing
    case mill = "Grain Mill" // Grain purchases doubled

    // Heating
    case fermenter = "Fermenter"    // Unlocks beer
    case boiler = "Boiler"          // Unlocks spirits
    case distiller = "Distiller"    // Unlocks high - proof spirits

    // Containers - Required for any production
    case tinCan = "Tin Can"         // Max production/day ~ 1 drink
    case bucket = "Bucket"          // Max production/day ~ 3 drink
    case carboy = "Carboy"          // Max production/day ~ 12 drink
    case barrel = "Barrel"          // Max production/day ~ 50 drink

    // Distribution
    case bottler = "Bottler"        // Inventory size * 10
    case keg = "Keg"                // Inventory size * 100

    // Testing & Purity
    case thermometer = "Thermometer"    // Production * 2
    case hydrometer = "Hydrometer"      // Production * 2
    case cheeseCloth = "Cheese Cloth"   // Production * 2
    case siphon = "Siphon"              // Production * 2

    var displayName: String { self.rawValue }

    var props: (category: Category, quality: Quality) {
        switch self {
        // Ingredients
        case .corn, .yeast, .sugar, .grapes, .malt, .barley:
            return (.ingredient, .bulk)

        case .rye, .juniper, .mash, .potato, .wheat, .molasses:
            return (.ingredient, .discount)

        // Starter
        case .wine, .beer:
            return (.consumable, .affordable)

        // Generic
        case .hooch, .bathtubGin, .moonshine:
            return (.consumable, .midrange)

        // Generic
        case .gin, .bourbon, .rum, .vodka, .brandy, .tequila, .whiskey:
            return (.consumable, .aboveAverage)

        case .champagne, .burgundy:
            return (.consumable, .superior)

        // Equipment Precursor
        case .parts:
            return (.equipmentParts, .discount)

        // Equipment
        case .tinCan, .bucket, .barrel, .keg, .thermometer, .hydrometer, .cheeseCloth, .siphon:
            return (.equipment, .lavish)

        case .carboy, .mill, .fermenter, .boiler, .distiller, .bottler:
            return (.equipment, .lavish)
        }
    }

    static let ingredients = Self.allCases.filter(\.isIngredient)
    static let consumables = Self.allCases.filter(\.isConsumable)
    static let equipmentParts = Self.allCases.filter(\.isParts)
    static let equipments = Self.allCases.filter(\.isEquipment)

    var isIngredient: Bool { self.props.category == .ingredient }
    var isConsumable: Bool { self.props.category == .consumable }
    var isEquipment: Bool { self.props.category == .equipment }
    var isParts: Bool { self.props.category == .equipmentParts }
}

extension Product: RandomExample {
    static func random() -> Self { self.allCases.randomElement() ?? .beer }
    static func random(in category: Category) -> Self {
        self.allCases.filter { $0.props.category == category }.randomElement() ?? .beer
    }
}

extension Product {
    var randomBrand: Brand? {
        switch self.props.category {
        case .ingredient, .equipmentParts, .equipment:
            return nil
        case .consumable:
            return Brand.random()
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
        case .equipment:
            return Int.random(in: 1...2)
        }
    }

    func randomProduction() -> Int {
        switch self {
        case .ingredient:
            return Int.random(in: 0...3)
        case .consumable:
            return Int.random(in: 0...2) == 0 ? 1 : 0
        case .equipmentParts:
            return Int.random(in: 0...5) == 0 ? 1 : 0
        case .equipment:
            return Int.random(in: 0...25) == 0 ? 1 : 0
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
        case 80...100:
            return .equipment
        default:
            return .ingredient
        }
    }

    static func randomStarterResource() -> Product.Category {
        switch Int.random(in: 0...100) {
        case 0..<75:
            return .ingredient
        case 70..<85:
            return .consumable
        case 85..<95:
            return .equipmentParts
        case 95...100:
            return .equipment
        default:
            return .ingredient
        }
    }
}
