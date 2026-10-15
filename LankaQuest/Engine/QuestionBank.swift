//
//  QuestionBank.swift
//  LankaQuest
//

import Foundation

/// Hands out questions for an age band without repeats until that band runs out.
final class QuestionBank {
    let questions: [Question]
    private var usedIDs: Set<Int> = []

    init(questions: [Question]) {
        self.questions = questions
    }

    /// Loads questions.json from the app bundle.
    static func fromBundle(_ bundle: Bundle = .main) -> QuestionBank {
        guard let url = bundle.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            assertionFailure("questions.json is missing or invalid")
            return QuestionBank(questions: [])
        }
        return QuestionBank(questions: questions)
    }

    /// A random unused question for the band in the chosen categories.
    /// If no question matches the categories, any question for the band is used.
    func nextQuestion(for band: AgeBand,
                      categories: Set<QuestionCategory> = Set(QuestionCategory.allCases)) -> Question? {
        let bandPool = questions.filter { $0.ageBand == band }
        let filtered = bandPool.filter { categories.contains($0.kind) }
        let pool = filtered.isEmpty ? bandPool : filtered
        guard !pool.isEmpty else { return nil }

        var unused = pool.filter { !usedIDs.contains($0.id) }
        if unused.isEmpty {
            usedIDs.subtract(pool.map(\.id))
            unused = pool
        }
        guard let question = unused.randomElement() else { return nil }
        usedIDs.insert(question.id)
        return question
    }
}
