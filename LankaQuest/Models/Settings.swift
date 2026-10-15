//
//  Settings.swift
//  LankaQuest
//
//  Game options chosen on the Settings screen.
//

import SwiftUI

/// Question topics. Players can switch categories on or off in Settings.
enum QuestionCategory: String, Codable, CaseIterable, Identifiable {
    case culture = "Culture"
    case history = "History"
    case geography = "Geography"
    case nature = "Nature"
    case sport = "Sport"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .culture: "theatermasks.fill"
        case .history: "building.columns.fill"
        case .geography: "globe.asia.australia.fill"
        case .nature: "leaf.fill"
        case .sport: "trophy.fill"
        }
    }

    var color: Color {
        switch self {
        case .culture: .purple
        case .history: .orange
        case .geography: .blue
        case .nature: .green
        case .sport: .red
        }
    }
}

/// How long players get to answer, relative to their age band's normal time.
enum TimerSpeed: String, Codable, CaseIterable {
    case relaxed, normal, quick

    var title: String {
        switch self {
        case .relaxed: "Relaxed"
        case .normal: "Normal"
        case .quick: "Quick"
        }
    }

    var multiplier: Double {
        switch self {
        case .relaxed: 1.5
        case .normal: 1.0
        case .quick: 0.6
        }
    }

    var next: TimerSpeed {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}

/// All the options for one game.
struct GameSettings: Codable, Equatable {
    var rounds = 10
    var timerSpeed: TimerSpeed = .normal
    var categories: Set<QuestionCategory> = Set(QuestionCategory.allCases)
    var lifelinesEnabled = true
    var streakBonusEnabled = true

    static let roundOptions = [5, 10, 15]

    /// The next value in the rounds list (5 → 10 → 15 → 5).
    var nextRounds: Int {
        let options = Self.roundOptions
        let index = options.firstIndex(of: rounds) ?? 0
        return options[(index + 1) % options.count]
    }

    /// Short description shown on the player setup screen.
    var summary: String {
        "\(rounds) rounds · \(timerSpeed.title) timer · \(categories.count) of \(QuestionCategory.allCases.count) categories"
    }
}
