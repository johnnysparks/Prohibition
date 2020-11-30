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
        case lightEquipment
        case heavyEquipment

        static func random() -> Product.Category { self.allCases.randomElement() ?? .consumable }
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

    // Equipment

    // Parts
    case parts = "Machine Parts"

    // Grain processing
    case mill = "Grain Mill" // Get more units per purchased grain

    // Heating
    case fermenter = "Fermenter"    // Unlocks beer
    case boiler = "Boiler"          // Unlocks spirits
    case distiller = "Distiller"    // Unlocks high - proof spirits

    // Containers - Required for any production
    case tinCan = "Tin Can"
    case bucket = "Bucket"
    case carboy = "Carboy"
    case barrel = "Barrel"

    // Distribution
    case bottler = "Bottler"
    case keg = "Keg"

    // Testing & Purity
    case thermometer = "Thermometer"
    case hydrometer = "Hydrometer"
    case cheeseCloth = "Cheese Cloth"
    case siphon = "Siphon"

    var displayName: String { self.rawValue }

    var category: Category {
        switch self {
        // Ingredients
        case .corn, .yeast, .sugar, .grapes, .malt, .barley, .rye, .juniper, .mash, .potato, .wheat,
             .molasses:
            return .ingredient

        // Starter
        case .wine, .beer:
            return .consumable

        // Generic
        case .hooch, .bathtubGin, .moonshine:
            return .consumable

        // Generic
        case .gin, .bourbon, .rum, .vodka, .brandy, .tequila, .whiskey:
            return .consumable

        // Equipment Precursor
        case .parts:
            return .equipmentParts

        // Equipment
        case .tinCan, .bucket, .barrel, .keg, .thermometer, .hydrometer, .cheeseCloth, .siphon:
            return .lightEquipment

        case .carboy, .mill, .fermenter, .boiler, .distiller, .bottler:
            return .heavyEquipment
        }
    }

    static let ingredients = Self.allCases.filter(\.isIngredient)
    static let consumables = Self.allCases.filter(\.isConsumable)
    static let equipmentParts = Self.allCases.filter(\.isEquipmentParts)
    static let equipments = Self.allCases.filter(\.isEquipment)

    var isIngredient: Bool { self.category == .ingredient }
    var isConsumable: Bool { self.category == .consumable }
    var isEquipment: Bool { self.category == .lightEquipment}
    var isEquipmentParts: Bool { self.category == .equipmentParts }

}

extension Product: RandomExample {
    static func random() -> Self { self.allCases.randomElement() ?? .beer }
    static func random(in category: Category) -> Self {
        self.allCases.filter { $0.category == category }.randomElement() ?? .beer
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

    func randomProduction() -> Int {
        switch self {
        case .ingredient:
            return Int.random(in: 0...3)
        case .consumable:
            return Int.random(in: 0...2) == 0 ? 1 : 0
        case .equipmentParts:
            return Int.random(in: 0...5) == 0 ? 1 : 0
        case .lightEquipment:
            return Int.random(in: 0...25) == 0 ? 1 : 0
        case .heavyEquipment:
            return Int.random(in: 0...50) == 0 ? 1 : 0
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
