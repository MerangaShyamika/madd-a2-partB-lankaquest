//
//  Player.swift
//  LankaQuest
//

import Foundation

/// One person in the game. `position` is the index of the province they have reached.
struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var avatar: Avatar
    var ageBand: AgeBand
    var position = 0
    var score = 0
    var correctAnswers = 0
    /// Correct answers in a row right now.
    var streak = 0
    /// Longest run of correct answers this game.
    var bestStreak = 0
    /// Each player may use the 50:50 lifeline once per game.
    var usedFiftyFifty = false

    init(id: UUID = UUID(), name: String, avatar: Avatar, ageBand: AgeBand) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.ageBand = ageBand
    }
}
