//
//  LankaQuestTests.swift
//  LankaQuestTests
//
//  Unit tests for the game rules (GameEngine), the question bank and saved data.
//

import XCTest
@testable import LankaQuest

final class GameEngineTests: XCTestCase {

    /// Three questions per age band: ids 1–3 (kids), 11–13 (teens), 21–23 (adults). Answer is always B.
    private func makeQuestions(category: String = "History") -> [Question] {
        AgeBand.allCases.enumerated().flatMap { bandIndex, band in
            (1...3).map { n in
                Question(id: bandIndex * 10 + n, ageBand: band, category: category,
                         text: "Q\(n)", options: ["A", "B", "C", "D"], answerIndex: 1, funFact: "Fact")
            }
        }
    }

    @MainActor
    private func makeEngine(players count: Int = 2, settings: GameSettings = GameSettings()) -> GameEngine {
        let engine = GameEngine(bank: QuestionBank(questions: makeQuestions()))
        let players = (0..<count).map { Player(name: "P\($0)", avatar: Avatar.allCases[$0], ageBand: .adults) }
        engine.start(with: players, settings: settings)
        return engine
    }

    /// Asks a question for the current player and answers it. Returns the points scored.
    @MainActor
    @discardableResult
    private func playTurn(_ engine: GameEngine, correctly: Bool) -> Int {
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else {
            XCTFail("Expected a question")
            return 0
        }
        engine.answer(correctly ? question.answerIndex : (question.answerIndex + 1) % question.options.count)
        let points = engine.lastPoints
        engine.endTurn()
        return points
    }

    // MARK: - Starting and turns

    @MainActor
    func testStartNeedsTwoToFourPlayers() {
        let engine = GameEngine(bank: QuestionBank(questions: makeQuestions()))
        XCTAssertFalse(engine.start(with: [Player(name: "Solo", avatar: .hare, ageBand: .kids)]))
        XCTAssertEqual(engine.phase, .setup)

        let five = (0..<5).map { Player(name: "P\($0)", avatar: .hare, ageBand: .kids) }
        XCTAssertFalse(engine.start(with: five))
    }

    @MainActor
    func testTurnsRotateAndRoundsAdvance() {
        let engine = makeEngine(players: 3)
        playTurn(engine, correctly: false)
        XCTAssertEqual(engine.currentIndex, 1)
        playTurn(engine, correctly: false)
        XCTAssertEqual(engine.currentIndex, 2)
        playTurn(engine, correctly: false)

        XCTAssertEqual(engine.currentIndex, 0)
        XCTAssertEqual(engine.round, 2)
    }

    // MARK: - Answers and scoring

    @MainActor
    func testCorrectAnswerMovesAndScores() {
        let engine = makeEngine()
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }
        let timeLeft = engine.timeRemaining

        engine.answer(question.answerIndex)

        XCTAssertEqual(engine.players[0].position, 1)
        XCTAssertEqual(engine.players[0].score, 10 + timeLeft)
        XCTAssertEqual(engine.lastPoints, 10 + timeLeft)
        XCTAssertEqual(engine.players[0].correctAnswers, 1)
    }

    @MainActor
    func testWrongAnswerDoesNotMove() {
        let engine = makeEngine()
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }
        let wrong = (question.answerIndex + 1) % 4

        engine.answer(wrong)

        XCTAssertEqual(engine.players[0].position, 0)
        XCTAssertEqual(engine.players[0].score, 0)
        XCTAssertEqual(engine.turn, .revealed(question, chosen: wrong, correct: false))
    }

    @MainActor
    func testRunningOutOfTimeCountsAsWrong() {
        let engine = makeEngine()
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }

        for _ in 0..<engine.timeLimit(for: .adults) { engine.tick() }

        XCTAssertEqual(engine.turn, .revealed(question, chosen: nil, correct: false))
        XCTAssertEqual(engine.players[0].position, 0)
    }

    @MainActor
    func testPauseStopsTheTimer() {
        let engine = makeEngine()
        engine.askQuestion()
        let before = engine.timeRemaining

        engine.isPaused = true
        engine.tick()

        XCTAssertEqual(engine.timeRemaining, before)
    }

    // MARK: - Streak bonus

    @MainActor
    func testThirdCorrectAnswerInARowScoresDouble() {
        let engine = makeEngine()
        for _ in 0..<2 {
            playTurn(engine, correctly: true)   // P0
            playTurn(engine, correctly: false)  // P1
        }
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }
        let timeLeft = engine.timeRemaining
        XCTAssertTrue(engine.nextAnswerIsDouble)

        engine.answer(question.answerIndex)

        XCTAssertEqual(engine.lastPoints, (10 + timeLeft) * 2)
        XCTAssertEqual(engine.players[0].streak, 3)
        XCTAssertEqual(engine.players[0].bestStreak, 3)
    }

    @MainActor
    func testWrongAnswerResetsStreak() {
        let engine = makeEngine()
        playTurn(engine, correctly: true)   // P0 streak 1
        playTurn(engine, correctly: false)  // P1
        playTurn(engine, correctly: false)  // P0 wrong

        XCTAssertEqual(engine.players[0].streak, 0)
        XCTAssertEqual(engine.players[0].bestStreak, 1)
    }

    @MainActor
    func testStreakBonusCanBeTurnedOff() {
        var settings = GameSettings()
        settings.streakBonusEnabled = false
        let engine = makeEngine(settings: settings)
        for _ in 0..<2 {
            playTurn(engine, correctly: true)
            playTurn(engine, correctly: false)
        }
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }
        let timeLeft = engine.timeRemaining

        engine.answer(question.answerIndex)

        XCTAssertEqual(engine.lastPoints, 10 + timeLeft)
    }

    // MARK: - 50:50 lifeline

    @MainActor
    func testFiftyFiftyHidesTwoWrongAnswersOnce() {
        let engine = makeEngine()
        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }
        XCTAssertTrue(engine.canUseFiftyFifty)

        engine.useFiftyFifty()

        XCTAssertEqual(engine.hiddenOptions.count, 2)
        XCTAssertFalse(engine.hiddenOptions.contains(question.answerIndex))
        XCTAssertFalse(engine.canUseFiftyFifty, "Lifeline can only be used once per game")
        XCTAssertTrue(engine.players[0].usedFiftyFifty)
    }

    @MainActor
    func testHiddenOptionCannotBeChosen() {
        let engine = makeEngine()
        engine.askQuestion()
        engine.useFiftyFifty()
        guard let hidden = engine.hiddenOptions.first else { return XCTFail("Expected hidden options") }

        engine.answer(hidden)

        if case .asking = engine.turn {
            // Still waiting for a real answer, as expected.
        } else {
            XCTFail("A hidden option should be ignored")
        }
    }

    @MainActor
    func testLifelineCanBeTurnedOff() {
        var settings = GameSettings()
        settings.lifelinesEnabled = false
        let engine = makeEngine(settings: settings)
        engine.askQuestion()

        XCTAssertFalse(engine.canUseFiftyFifty)
        engine.useFiftyFifty()
        XCTAssertTrue(engine.hiddenOptions.isEmpty)
    }

    // MARK: - Settings

    @MainActor
    func testRoundsSettingEndsTheGame() {
        var settings = GameSettings()
        settings.rounds = 5
        let engine = makeEngine(settings: settings)
        for _ in 0..<(5 * 2) {
            playTurn(engine, correctly: false)
        }
        XCTAssertEqual(engine.phase, .finished)
    }

    @MainActor
    func testTimerSpeedChangesTimeLimit() {
        var settings = GameSettings()
        settings.timerSpeed = .quick
        let quick = makeEngine(settings: settings)
        XCTAssertEqual(quick.timeLimit(for: .adults), 9)   // 15 × 0.6

        settings.timerSpeed = .relaxed
        let relaxed = makeEngine(settings: settings)
        XCTAssertEqual(relaxed.timeLimit(for: .kids), 38)  // 25 × 1.5, rounded
    }

    func testGameSettingsCycleRounds() {
        var settings = GameSettings()
        XCTAssertEqual(settings.rounds, 10)
        settings.rounds = settings.nextRounds
        XCTAssertEqual(settings.rounds, 15)
        settings.rounds = settings.nextRounds
        XCTAssertEqual(settings.rounds, 5)
    }

    // MARK: - Winning

    @MainActor
    func testReachingTheFinishWinsTheGame() {
        let engine = makeEngine()
        var turns = 0
        while engine.phase == .playing && turns < 100 {
            playTurn(engine, correctly: engine.currentIndex == 0)
            turns += 1
        }

        XCTAssertEqual(engine.phase, .finished)
        XCTAssertEqual(engine.winner?.name, "P0")
        XCTAssertEqual(engine.winner?.position, GameEngine.finishPosition)
    }

    @MainActor
    func testRankingUsesPositionThenScore() {
        let engine = makeEngine(players: 2)
        playTurn(engine, correctly: false)
        playTurn(engine, correctly: true)

        XCTAssertEqual(engine.rankedPlayers.first?.name, "P1")
    }

    @MainActor
    func testFinishEarlyShowsResults() {
        let engine = makeEngine()
        engine.isPaused = true
        engine.finishEarly()
        XCTAssertEqual(engine.phase, .finished)
        XCTAssertFalse(engine.isPaused)
    }

    // MARK: - Question bank

    @MainActor
    func testQuestionsMatchPlayerAgeBand() {
        let engine = GameEngine(bank: QuestionBank(questions: makeQuestions()))
        engine.start(with: [Player(name: "Kid", avatar: .hare, ageBand: .kids),
                            Player(name: "Gran", avatar: .bird, ageBand: .adults)])

        engine.askQuestion()
        guard case .asking(let question) = engine.turn else { return XCTFail("Expected a question") }

        XCTAssertEqual(question.ageBand, .kids)
        XCTAssertEqual(engine.timeRemaining, engine.timeLimit(for: .kids))
    }

    func testQuestionBankDoesNotRepeatUntilEmpty() {
        let bank = QuestionBank(questions: makeQuestions())
        let ids = (0..<3).compactMap { _ in bank.nextQuestion(for: .teens)?.id }
        XCTAssertEqual(Set(ids).count, 3, "All three teen questions should be different")
        XCTAssertNotNil(bank.nextQuestion(for: .teens), "Bank should start again when empty")
    }

    func testQuestionBankRespectsCategories() {
        let questions = makeQuestions(category: "History") + [
            Question(id: 99, ageBand: .teens, category: "Sport", text: "S", options: ["A", "B", "C", "D"],
                     answerIndex: 0, funFact: "F")
        ]
        let bank = QuestionBank(questions: questions)
        for _ in 0..<5 {
            XCTAssertEqual(bank.nextQuestion(for: .teens, categories: [.sport])?.kind, .sport)
        }
    }

    func testBundledQuestionsAreValid() {
        let bank = QuestionBank.fromBundle()
        XCTAssertGreaterThanOrEqual(bank.questions.count, 45)
        for question in bank.questions {
            XCTAssertEqual(question.options.count, 4, "Question \(question.id) needs 4 options")
            XCTAssertTrue(question.options.indices.contains(question.answerIndex), "Bad answer for \(question.id)")
            XCTAssertNotNil(QuestionCategory(rawValue: question.category), "Unknown category in \(question.id)")
        }
        XCTAssertEqual(Set(bank.questions.map(\.id)).count, bank.questions.count, "Question ids must be unique")
        for band in AgeBand.allCases {
            XCTAssertFalse(bank.questions.filter { $0.ageBand == band }.isEmpty, "No questions for \(band)")
        }
    }

    // MARK: - Saved data

    func testHallOfFameRecordsGames() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "LankaQuestTests"))
        defaults.removePersistentDomain(forName: "LankaQuestTests")
        var amma = Player(name: "Amma", avatar: .bird, ageBand: .adults)
        amma.score = 120
        let kid = Player(name: "Nimal", avatar: .hare, ageBand: .kids)

        PlayerStore.recordGame(players: [amma, kid], winnerName: "Amma", defaults: defaults)
        PlayerStore.recordGame(players: [amma, kid], winnerName: "Amma", defaults: defaults)

        let hall = PlayerStore.hallOfFame(defaults: defaults)
        XCTAssertEqual(hall.first?.name, "Amma")
        XCTAssertEqual(hall.first?.wins, 2)
        XCTAssertEqual(hall.first?.games, 2)
        XCTAssertEqual(hall.first?.bestScore, 120)
        XCTAssertEqual(PlayerStore.wins(defaults: defaults)["Nimal"], 0)
    }

    func testSettingsAreSaved() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "LankaQuestSettingsTests"))
        defaults.removePersistentDomain(forName: "LankaQuestSettingsTests")
        var settings = GameSettings()
        settings.rounds = 15
        settings.categories = [.nature]

        SettingsStore.save(settings, defaults: defaults)

        XCTAssertEqual(SettingsStore.load(defaults: defaults), settings)
    }
}
