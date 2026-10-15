//
//  ResultsView.swift
//  LankaQuest
//

import SwiftUI

/// Confetti, an animated podium, game highlights, then play again or go back.
struct ResultsView: View {
    let engine: GameEngine
    let onMainMenu: () -> Void

    @State private var showPodium = false
    @State private var recorded = false
    @FocusState private var playAgainFocused: Bool

    var body: some View {
        let ranked = engine.rankedPlayers

        ZStack {
            ConfettiView()

            VStack(spacing: 26) {
                VStack(spacing: 4) {
                    Text("Champion of the island")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.75))
                    GradientTitle(text: ranked.first.map { "\($0.name) wins!" } ?? "Game over", size: 84)
                }

                HStack(alignment: .bottom, spacing: 36) {
                    ForEach(podiumOrder(ranked)) { entry in
                        PodiumColumn(player: entry.player, place: entry.place, isVisible: showPodium)
                    }
                }
                .frame(height: 450)

                HStack(spacing: 30) {
                    highlights
                }

                HStack(spacing: 30) {
                    Button { engine.playAgain() } label: {
                        Label("Play again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.lqProminent)
                    .focused($playAgainFocused)

                    Button { engine.newGame() } label: {
                        Label("New players", systemImage: "person.3.fill")
                    }
                    .buttonStyle(.lq)

                    Button(action: onMainMenu) {
                        Label("Main menu", systemImage: "house.fill")
                    }
                    .buttonStyle(.lq)
                }
            }
        }
        .onAppear {
            if !recorded {
                PlayerStore.recordGame(players: engine.players, winnerName: ranked.first?.name)
                recorded = true
            }
            withAnimation(.spring(duration: 1.0).delay(0.3)) {
                showPodium = true
            }
            playAgainFocused = true
        }
    }

    @ViewBuilder
    private var highlights: some View {
        if let sharpest = engine.players.max(by: { $0.correctAnswers < $1.correctAnswers }) {
            stat("Sharpest mind", value: "\(sharpest.name) · \(sharpest.correctAnswers) correct",
                 icon: "brain.head.profile")
        }
        if let hottest = engine.players.max(by: { $0.bestStreak < $1.bestStreak }), hottest.bestStreak > 0 {
            stat("Hottest streak", value: "\(hottest.name) · \(hottest.bestStreak) in a row", icon: "flame.fill")
        }
    }

    private func stat(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.lqGold)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(value)
                    .font(.headline)
            }
        }
        .glassCard()
    }

    /// Classic podium order: 2nd, 1st, 3rd, then 4th.
    private func podiumOrder(_ ranked: [Player]) -> [PodiumEntry] {
        let entries = ranked.enumerated().map { PodiumEntry(player: $0.element, place: $0.offset + 1) }
        return [2, 1, 3, 4].compactMap { place in entries.first { $0.place == place } }
    }
}

struct PodiumEntry: Identifiable {
    let player: Player
    let place: Int
    var id: UUID { player.id }
}

/// One podium step that grows up from the floor. The winner wears a crown.
struct PodiumColumn: View {
    let player: Player
    let place: Int
    let isVisible: Bool

    private var height: CGFloat {
        let heights: [Int: CGFloat] = [1: 270, 2: 200, 3: 145]
        return heights[place] ?? 100
    }

    private var medal: Color {
        let colors: [Int: Color] = [1: .lqGold, 2: Color(white: 0.82), 3: .orange]
        return colors[place] ?? .gray
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .top) {
                AvatarBadge(avatar: player.avatar, size: place == 1 ? 110 : 84)
                if place == 1 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(Color.lqGold)
                        .shadow(color: Color.lqGold, radius: 10)
                        .offset(y: -50)
                }
            }
            Text(player.name)
                .font(.title3.bold())
            Text("\(player.score) pts")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.75))
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [medal, medal.opacity(0.55)], startPoint: .top, endPoint: .bottom))
                Text("\(place)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.55))
                    .padding(.top, 8)
            }
            .frame(width: 230, height: isVisible ? height : 0)
            .clipped()
        }
        .accessibilityElement(children: .combine)
    }
}
