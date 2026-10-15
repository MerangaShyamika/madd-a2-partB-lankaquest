//
//  AgeBand.swift
//  LankaQuest
//

import Foundation

/// Question difficulty matched to the player's age, so every family member can win.
enum AgeBand: String, Codable, CaseIterable, Identifiable {
    case kids, teens, adults

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kids: "Kids (6–12)"
        case .teens: "Teens (13–17)"
        case .adults: "Adults (18+)"
        }
    }

    var icon: String {
        switch self {
        case .kids: "face.smiling"
        case .teens: "graduationcap.fill"
        case .adults: "person.fill"
        }
    }

    /// Younger players get more time to read and answer (before the timer speed setting).
    var secondsPerQuestion: Int {
        switch self {
        case .kids: 25
        case .teens: 20
        case .adults: 15
        }
    }

    /// The next band, used when a player presses their age button.
    var next: AgeBand {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}
