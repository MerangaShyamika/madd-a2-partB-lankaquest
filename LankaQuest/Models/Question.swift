//
//  Question.swift
//  LankaQuest
//

import Foundation

/// A multiple-choice question loaded from questions.json.
struct Question: Identifiable, Codable, Hashable {
    let id: Int
    let ageBand: AgeBand
    let category: String
    let text: String
    let options: [String]
    let answerIndex: Int
    let funFact: String

    /// The category as a type (unknown names count as Culture).
    var kind: QuestionCategory {
        QuestionCategory(rawValue: category) ?? .culture
    }
}
