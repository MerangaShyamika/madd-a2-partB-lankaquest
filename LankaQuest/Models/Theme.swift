//
//  Theme.swift
//  LankaQuest
//
//  Brand colours and the player avatars.
//

import SwiftUI

/// LankaQuest colours, inspired by the Sri Lankan flag and landscape.
extension Color {
    static let lqMaroon = Color(red: 0.55, green: 0.10, blue: 0.16)
    static let lqGold = Color(red: 0.98, green: 0.73, blue: 0.15)
    static let lqSea = Color(red: 0.05, green: 0.32, blue: 0.48)
    static let lqLand = Color(red: 0.22, green: 0.55, blue: 0.30)
}

/// Player token shown on the map and scoreboard.
enum Avatar: String, Codable, CaseIterable {
    case hare, tortoise, bird, fish, ladybug, leaf

    /// SF Symbol used to draw the avatar.
    var symbol: String {
        switch self {
        case .hare: "hare.fill"
        case .tortoise: "tortoise.fill"
        case .bird: "bird.fill"
        case .fish: "fish.fill"
        case .ladybug: "ladybug.fill"
        case .leaf: "leaf.fill"
        }
    }

    var title: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .hare: .orange
        case .tortoise: .green
        case .bird: .blue
        case .fish: .teal
        case .ladybug: .red
        case .leaf: .mint
        }
    }

    /// The next avatar, used when a player presses their avatar to change it.
    var next: Avatar {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}
