//
//  PlayerStore.swift
//  LankaQuest
//

import Foundation

/// One name in the Hall of Fame.
struct HallEntry: Identifiable, Codable, Equatable {
    var name: String
    var wins = 0
    var games = 0
    var bestScore = 0

    var id: String { name }
}

/// Remembers the family's players and the Hall of Fame on the Apple TV.
/// tvOS may clear local storage when space is low, so only small data is kept here.
enum PlayerStore {
    private static let playersKey = "savedPlayers"
    private static let hallKey = "hallOfFame"

    static func loadPlayers(defaults: UserDefaults = .standard) -> [Player] {
        guard let data = defaults.data(forKey: playersKey),
              let players = try? JSONDecoder().decode([Player].self, from: data) else { return [] }
        return players
    }

    static func savePlayers(_ players: [Player], defaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(players) {
            defaults.set(data, forKey: playersKey)
        }
    }

    /// Everyone who has played, most wins first (best score breaks ties).
    static func hallOfFame(defaults: UserDefaults = .standard) -> [HallEntry] {
        loadHall(defaults).values.sorted { ($0.wins, $0.bestScore) > ($1.wins, $1.bestScore) }
    }

    static func wins(defaults: UserDefaults = .standard) -> [String: Int] {
        loadHall(defaults).mapValues(\.wins)
    }

    /// Adds a finished game to every player's record.
    static func recordGame(players: [Player], winnerName: String?, defaults: UserDefaults = .standard) {
        var hall = loadHall(defaults)
        for player in players {
            var entry = hall[player.name] ?? HallEntry(name: player.name)
            entry.games += 1
            entry.bestScore = max(entry.bestScore, player.score)
            if player.name == winnerName {
                entry.wins += 1
            }
            hall[player.name] = entry
        }
        if let data = try? JSONEncoder().encode(hall) {
            defaults.set(data, forKey: hallKey)
        }
    }

    private static func loadHall(_ defaults: UserDefaults) -> [String: HallEntry] {
        guard let data = defaults.data(forKey: hallKey),
              let hall = try? JSONDecoder().decode([String: HallEntry].self, from: data) else { return [:] }
        return hall
    }
}

/// Saves the options chosen on the Settings screen.
enum SettingsStore {
    private static let key = "gameSettings"

    static func load(defaults: UserDefaults = .standard) -> GameSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else { return GameSettings() }
        return settings
    }

    static func save(_ settings: GameSettings, defaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: key)
        }
    }
}
