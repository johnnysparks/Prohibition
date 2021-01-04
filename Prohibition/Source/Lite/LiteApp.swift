//
//  LiteApp.swift
//  Prohibition
//
//  Created by Johnny Sparks  on 12/20/20.
//

import ComposableArchitecture
import SwiftUI

enum MarketPrice: Int {
    case veryLow = 1
    case low = 2
    case average = 3
    case high = 4
    case veryHigh = 5

    /// Buying from cities fits a balanced curve
    static func buyPrice(for citySupply: Int) -> MarketPrice {
        switch citySupply {
        case 0..<15: return .veryHigh
        case 15..<40: return .high
        case 40..<60: return .average
        case 60..<85: return .low
        case 85..<100: return .veryLow
        default: return .veryLow
        }
    }

    /// Selling  to cities is always a little worse of a deal
    static func sellPrice(for citySupply: Int) -> MarketPrice {
        switch citySupply {
        case 0..<10: return .veryHigh
        case 10..<35: return .high
        case 35..<55: return .average
        case 55..<80: return .low
        case 80..<100: return .veryLow
        default: return .veryLow
        }
    }

    var sellColor: Color {
        switch self {
        case .veryLow: return .red
        case .low: return .black
        case .average: return .black
        case .high: return .black
        case .veryHigh: return .green
        }
    }

    var buyColor: Color {
        switch self {
        case .veryLow: return .green
        case .low: return .black
        case .average: return .black
        case .high: return .black
        case .veryHigh: return .red
        }
    }

    var display: String { "$\(self.rawValue)" }
}

struct LiteEnvironment {}

struct Wallet: Equatable, Codable {
    var stock: Int
    var money: Int

    var isBroke: Bool { self.money <= 0 }
    var isStockEmpty: Bool { self.stock <= 0 }
}

struct Game: Equatable, Codable {
    enum RunState: Int, Equatable, Codable {
        case unstarted
        case running
        case ended
    }

    var inventories: [City: Wallet] = City.allCases.prefix(10)
        .reduce(into: [:], { $0[$1] = Wallet(stock: Int.random(in: 1..<100), money: 0) })
    var cities: [City] = Array(City.allCases.prefix(10))
    var location: City = .nashville
    var player = Wallet(stock: 0, money: 100)
    var runState: RunState = .unstarted
    var turnsLeft = 52

    var cityWallet: Wallet {
        self.inventories[self.location] ?? Wallet(stock: 0, money: 0)
    }

    func wallet(for city: City) -> Wallet {
        self.inventories[city] ?? Wallet(stock: 0, money: 0)
    }
}

struct LiteState: Equatable {
    var highScores: [Int] = []
    var last: Game?
    var current = Game()
}

enum GameAction {
    case loadGame
    case newGame
    case cacheWrite
    case cacheRestore
}

enum PlayerAction {
    case travel(City)
    case buy(units: Int, total: Int)
    case sell(units: Int, total: Int)
}

enum LiteAction {
    case game(GameAction)
    case play(PlayerAction)
}

let liteReducer = Reducer<LiteState, LiteAction, LiteEnvironment> { state, action, _ in
    print("\(action)")

    switch action {
    case .game(let gameAction):
        switch gameAction {
        case .loadGame:
            guard let next = state.last, next.runState != .ended else {
                break
            }

            state.current = next
        case .newGame:
            state.current = Game()
            state.current.runState = .running

        case .cacheRestore:
            guard let encodedGame = UserDefaults.standard.value(forKey: "game") as? Data,
                  let game = try? JSONDecoder().decode(Game.self, from: encodedGame) else { break }

            guard let encodedScores = UserDefaults.standard.value(forKey: "highScores") as? Data,
                  let scores = try? JSONDecoder().decode([Int].self, from: encodedScores) else { break }

            state.last = game
            state.highScores = scores

        case .cacheWrite:
            guard let encodedGame = try? JSONEncoder().encode(state.current) else { break }
            UserDefaults.standard.setValue(encodedGame, forKey: "game")

            guard let encodedScores = try? JSONEncoder().encode(state.highScores) else { break }
            UserDefaults.standard.setValue(encodedScores, forKey: "highScores")
        }

    case .play(let playAction):
        switch playAction {
        case .travel(let city):
            guard state.current.turnsLeft > 0 else {
                state.highScores.append(state.current.player.money)
                state.current.runState = .ended
                break
            }

            state.current.turnsLeft -= 1
            state.current.location = city
        case let .buy(qty, total):
            state.current.inventories[state.current.location]?.money += total
            state.current.inventories[state.current.location]?.stock -= qty

            state.current.player.money -= total
            state.current.player.stock += qty

        case let .sell(qty, total):
            state.current.inventories[state.current.location]?.money -= total
            state.current.inventories[state.current.location]?.stock += qty

            state.current.player.money += total
            state.current.player.stock -= qty
        }
    }

    return .none
}

let liteStore = Store<LiteState, LiteAction>(
    initialState: .init(),
    reducer: liteReducer,
    environment: LiteEnvironment()
)

@main
struct LiteApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WithViewStore(liteStore.scope(state: \.current.runState)) { store in
                self.screen(for: store.state)
            }
        }
        .onChange(of: self.scenePhase) { phase in
            switch phase {
            case .active:
                ViewStore(liteStore).send(.game(.cacheRestore))
            case .background:
                ViewStore(liteStore).send(.game(.cacheWrite))
            case .inactive:
                break
            @unknown default:
                print("Unknown ScenePhase change.")
            }
        }
    }

    func screen(for runState: Game.RunState) -> some View {
        switch runState {
        case .unstarted:
            return AnyView(TitleScreenView(appStore: liteStore))
        case .running:
//            return AnyView(GameScreenView(appStore: liteStore))
            return AnyView(CityListMapView(appStore: liteStore))
        case .ended:
            return AnyView(GameOverScreenView(appStore: liteStore))
        }
    }
}
