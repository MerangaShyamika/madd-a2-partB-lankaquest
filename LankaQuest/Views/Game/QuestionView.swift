//
//  QuestionView.swift
//  LankaQuest
//

import SwiftUI

/// Full-screen question with four focusable answer cards, a countdown ring,
/// the 50:50 lifeline and a result panel.
struct QuestionView: View {
    let engine: GameEngine

    enum Field: Hashable {
        case option(Int)
        case lifeline
        case next
    }

    @FocusState private var focus: Field?

    private var question: Question? {
        switch engine.turn {
        case .asking(let question): return question
        case .revealed(let question, _, _): return question
        case .waiting: return nil
        }
    }

    private var reveal: (chosen: Int?, correct: Bool)? {
        if case .revealed(_, let chosen, let correct) = engine.turn {
            return (chosen, correct)
        }
        return nil
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            if let question = question, let player = engine.currentPlayer {
                VStack(spacing: 26) {
                    header(player: player, question: question)

                    Text(question.text)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .glassCard()

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 36), GridItem(.flexible(), spacing: 36)],
                              spacing: 24) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            let hidden = engine.hiddenOptions.contains(index)
                            Button {
                                engine.answer(index)
                            } label: {
                                optionLabel(option, index: index, question: question)
                            }
                            .buttonStyle(.card)
                            .focused($focus, equals: .option(index))
                            .disabled(hidden)
                            .opacity(hidden ? 0.2 : 1)
                        }
                    }

                    if let result = reveal {
                        revealPanel(result, question: question, player: player)
                    } else if engine.canUseFiftyFifty {
                        Button {
                            engine.useFiftyFifty()
                            focus = firstVisibleOption(in: question)
                        } label: {
                            Label("Use my 50:50 lifeline", systemImage: "circle.lefthalf.filled")
                        }
                        .buttonStyle(.lqCompact)
                        .focused($focus, equals: .lifeline)
                    }
                }
                .padding(.horizontal, 60)
                .frame(maxWidth: 1600)
            }
        }
        .disabled(engine.isPaused)
        .task(id: question?.id) { await runTimer() }
        .onAppear { focus = .option(0) }
        .onChange(of: engine.turn) { _, newTurn in
            if case .revealed = newTurn {
                focus = .next
            } else if case .asking = newTurn {
                focus = .option(0)
            }
        }
    }

    /// Counts down once a second while the question is open.
    private func runTimer() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard case .asking = engine.turn else { return }
            engine.tick()
        }
    }

    private func firstVisibleOption(in question: Question) -> Field {
        let index = question.options.indices.first { !engine.hiddenOptions.contains($0) } ?? 0
        return .option(index)
    }

    private func header(player: Player, question: Question) -> some View {
        HStack(spacing: 24) {
            AvatarBadge(avatar: player.avatar, size: 84)
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.title.bold())
                HStack(spacing: 14) {
                    CategoryChip(category: question.kind)
                    Text(player.ageBand.title)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                    if engine.nextAnswerIsDouble && reveal == nil {
                        Label("Double points!", systemImage: "flame.fill")
                            .font(.callout.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
            TimerRing(remaining: engine.timeRemaining, total: engine.timeLimit(for: player.ageBand))
        }
    }

    /// Answer card. After answering, the right answer turns green and a wrong choice red.
    private func optionLabel(_ text: String, index: Int, question: Question) -> some View {
        let letter = ["A", "B", "C", "D"][index % 4]
        var background = Color.white.opacity(0.08)
        if let result = reveal {
            if index == question.answerIndex {
                background = Color.green.opacity(0.75)
            } else if index == result.chosen {
                background = Color.red.opacity(0.75)
            }
        }
        return HStack(spacing: 24) {
            Text(letter)
                .font(.title2.bold())
                .frame(width: 64, height: 64)
                .background(Color.lqGold, in: Circle())
                .foregroundStyle(.black)
            Text(text)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(background)
    }

    private func revealPanel(_ result: (chosen: Int?, correct: Bool), question: Question,
                             player: Player) -> some View {
        let title: String
        if result.correct {
            title = "Correct!"
        } else if result.chosen == nil {
            title = "Time's up!"
        } else {
            title = "Not this time"
        }
        let reached = Province.route[player.position]

        return VStack(spacing: 14) {
            HStack(spacing: 24) {
                Label(title, systemImage: result.correct ? "checkmark.seal.fill" : "xmark.octagon.fill")
                    .font(.title2.bold())
                    .foregroundStyle(result.correct ? Color.green : Color.orange)
                if result.correct {
                    Text("+\(engine.lastPoints)")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.lqGold)
                }
            }
            if result.correct {
                Text("You reached \(reached.name) Province: \(reached.landmark)")
                    .font(.headline)
            }
            Text("Did you know? \(question.funFact)")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
            Button {
                engine.endTurn()
            } label: {
                Label("Continue", systemImage: "arrow.right.circle.fill")
                    .padding(.horizontal, 20)
            }
            .buttonStyle(.lqProminent)
            .focused($focus, equals: .next)
        }
        .frame(maxWidth: .infinity)
        .glassCard(highlighted: result.correct)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

/// Countdown ring that turns from green to yellow to red.
struct TimerRing: View {
    let remaining: Int
    let total: Int

    private var fraction: Double {
        total > 0 ? Double(remaining) / Double(total) : 0
    }

    private var tint: Color {
        fraction > 0.5 ? .green : (fraction > 0.25 ? .yellow : .red)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.3))
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 14)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(tint, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.7), radius: 10)
                .animation(.linear(duration: 1), value: remaining)
            Text("\(remaining)")
                .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: remaining)
        }
        .frame(width: 130, height: 130)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(remaining) seconds left")
    }
}
