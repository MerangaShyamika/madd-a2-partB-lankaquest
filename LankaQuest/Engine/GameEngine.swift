//
//  GameEngine.swift
//  LankaQuest
//
//  All game rules live here, separate from the UI (MVVM), so they can be unit tested.
//

import Foundation
import Observation

@MainActor
@Observable
final class GameEngine {
    enum Phase: Equatable {
        case setup, playing, finished
    }

    enum Turn: Equatable {
        case waiting
        case asking(Question)
        case revealed(Question, chosen: Int?, correct: Bool)
    }

    static let finishPosition = Province.route.count - 1
    static let playerRange = 2...4
    /// Correct answers in a row needed before points are doubled.
    static let streakForBonus = 3

    private(set) var phase: Phase = .setup
    private(set) var players: [Player] = []
    private(set) var currentIndex = 0
    private(set) var round = 1
    private(set) var turn: Turn = .waiting
    private(set) var timeRemaining = 0
    private(set) var settings = GameSettings()
    /// Answer options removed by the 50:50 lifeline for the current question.
    private(set) var hiddenOptions: Set<Int> = []
    /// Points scored by the last answer (shown on the result panel).
    private(set) var lastPoints = 0
    var isPaused = false

    private let bank: QuestionBank

    init(bank: QuestionBank = .fromBundle()) {
        self.bank = bank
    }

    var currentPlayer: Player? {
        players.indices.contains(currentIndex) ? players[currentIndex] : nil
    }

    var maxRounds: Int { settings.rounds }

    /// Furthest along first; score breaks ties.
    var rankedPlayers: [Player] {
        players.sorted { ($0.position, $0.score) > ($1.position, $1.score) }
    }

    var winner: Player? {
        phase == .finished ? rankedPlayers.first : nil
    }

    /// Seconds allowed for an age band, adjusted by the timer speed setting (minimum 5).
    func timeLimit(for band: AgeBand) -> Int {
        max(5, Int((Double(band.secondsPerQuestion) * settings.timerSpeed.multiplier).rounded()))
    }

    /// True while a question is open and the current player still has their 50:50.
    var canUseFiftyFifty: Bool {
        guard settings.lifelinesEnabled, case .asking = turn, let player = currentPlayer else { return false }
        return !player.usedFiftyFifty
    }

    /// True when the current player's next correct answer will score double points.
    var nextAnswerIsDouble: Bool {
        guard settings.streakBonusEnabled, let player = currentPlayer else { return false }
        return player.streak + 1 >= Self.streakForBonus
    }

    /// Starts a new race. Needs 2 to 4 players.
    @discardableResult
    func start(with newPlayers: [Player], settings newSettings: GameSettings = GameSettings()) -> Bool {
        guard Self.playerRange.contains(newPlayers.count) else { return false }
        settings = newSettings
        players = newPlayers.map { player in
            var fresh = player
            fresh.position = 0
            fresh.score = 0
            fresh.correctAnswers = 0
            fresh.streak = 0
            fresh.bestStreak = 0
            fresh.usedFiftyFifty = false
            return fresh
        }
        currentIndex = 0
        round = 1
        turn = .waiting
        hiddenOptions = []
        lastPoints = 0
        isPaused = false
        phase = .playing
        return true
    }

    /// Shows a question for the current player's age band and starts their timer.
    func askQuestion() {
        guard phase == .playing, turn == .waiting,
              let player = currentPlayer,
              let question = bank.nextQuestion(for: player.ageBand, categories: settings.categories) else { return }
        hiddenOptions = []
        lastPoints = 0
        timeRemaining = timeLimit(for: player.ageBand)
        turn = .asking(question)
    }

    /// Correct answers move the player one province and score 10 points plus the seconds left.
    /// With the streak bonus on, the third correct answer in a row (and every one after) scores double.
    func answer(_ index: Int) {
        guard case .asking(let question) = turn, !hiddenOptions.contains(index) else { return }
        let correct = index == question.answerIndex
        if correct {
            players[currentIndex].streak += 1
            players[currentIndex].bestStreak = max(players[currentIndex].bestStreak, players[currentIndex].streak)
            var points = 10 + timeRemaining
            if settings.streakBonusEnabled && players[currentIndex].streak >= Self.streakForBonus {
                points *= 2
            }
            players[currentIndex].score += points
            players[currentIndex].correctAnswers += 1
            players[currentIndex].position = min(players[currentIndex].position + 1, Self.finishPosition)
            lastPoints = points
        } else {
            players[currentIndex].streak = 0
            lastPoints = 0
        }
        turn = .revealed(question, chosen: index, correct: correct)
    }

    /// Called once a second by the question screen. Running out of time counts as wrong.
    func tick() {
        guard case .asking(let question) = turn, !isPaused else { return }
        timeRemaining = max(timeRemaining - 1, 0)
        if timeRemaining == 0 {
            players[currentIndex].streak = 0
            lastPoints = 0
            turn = .revealed(question, chosen: nil, correct: false)
        }
    }

    /// Removes two wrong answers. Each player can do this once per game.
    func useFiftyFifty() {
        guard canUseFiftyFifty, case .asking(let question) = turn else { return }
        let wrong = question.options.indices.filter { $0 != question.answerIndex }.shuffled()
        hiddenOptions = Set(wrong.prefix(2))
        players[currentIndex].usedFiftyFifty = true
    }

    /// Passes the remote to the next player, or ends the game.
    func endTurn() {
        guard case .revealed = turn else { return }
        turn = .waiting
        hiddenOptions = []

        let reachedFinish = players[currentIndex].position >= Self.finishPosition
        let lastPlayerOfRound = currentIndex == players.count - 1
        if reachedFinish || (lastPlayerOfRound && round >= settings.rounds) {
            phase = .finished
            return
        }

        currentIndex = (currentIndex + 1) % players.count
        if currentIndex == 0 { round += 1 }
    }

    /// Ends the race now (from the pause menu) and shows the results.
    func finishEarly() {
        turn = .waiting
        isPaused = false
        phase = .finished
    }

    func playAgain() {
        start(with: players, settings: settings)
    }

    func newGame() {
        phase = .setup
        players = []
        turn = .waiting
        isPaused = false
    }
}
