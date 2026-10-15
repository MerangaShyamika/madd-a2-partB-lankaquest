//
//  GameBoardView.swift
//  LankaQuest
//

import SwiftUI

/// The race: island map on the left, scoreboard and current player on the right.
/// Play/Pause or Menu on the Siri Remote opens the pause menu.
struct GameBoardView: View {
    let engine: GameEngine
    let onMainMenu: () -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 56) {
                IslandMapView(players: engine.players, currentPlayerID: engine.currentPlayer?.id)
                    .frame(width: 620)
                sidePanel
            }
            .disabled(engine.turn != .waiting || engine.isPaused)

            if engine.turn != .waiting {
                QuestionView(engine: engine)
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
                    .zIndex(1)
            }

            if engine.isPaused {
                PauseMenuView(engine: engine, onMainMenu: onMainMenu)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .animation(.spring(duration: 0.5), value: engine.turn)
        .animation(.easeInOut, value: engine.isPaused)
        .onPlayPauseCommand { engine.isPaused.toggle() }
        .onExitCommand { engine.isPaused.toggle() }
    }

    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label("Round \(engine.round) of \(engine.maxRounds)", systemImage: "flag.fill")
                    .font(.headline)
                    .foregroundStyle(Color.lqGold)
                Spacer()
                Label("Play/Pause to pause", systemImage: "playpause.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack(spacing: 12) {
                ForEach(engine.players) { player in
                    ScoreRow(player: player, isCurrent: player.id == engine.currentPlayer?.id)
                }
            }

            Spacer(minLength: 0)

            if let player = engine.currentPlayer {
                currentPlayerCard(player)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currentPlayerCard(_ player: Player) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pass the remote to")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
            HStack(spacing: 22) {
                AvatarBadge(avatar: player.avatar, size: 90)
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                    Text("\(player.ageBand.title) · next stop: \(nextStop(for: player))")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            if engine.nextAnswerIsDouble {
                Label("On fire! A right answer now scores double", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
            }
            Button {
                engine.askQuestion()
            } label: {
                Label("Ask my question", systemImage: "questionmark.bubble.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.lqProminent)
        }
        .glassCard(highlighted: true)
    }

    private func nextStop(for player: Player) -> String {
        Province.route[min(player.position + 1, GameEngine.finishPosition)].name
    }
}

/// One line of the scoreboard with a progress bar and streak flame.
struct ScoreRow: View {
    let player: Player
    let isCurrent: Bool

    private var progress: Double {
        Double(player.position) / Double(GameEngine.finishPosition)
    }

    var body: some View {
        HStack(spacing: 18) {
            AvatarBadge(avatar: player.avatar, size: 56)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(player.name)
                        .font(.headline)
                    if player.streak >= 2 {
                        Label("\(player.streak)", systemImage: "flame.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                    }
                }
                ProgressView(value: progress)
                    .tint(Color.lqGold)
                Text(Province.route[player.position].name)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Text("\(player.score)")
                .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                .frame(width: 110, alignment: .trailing)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(isCurrent ? Color.lqGold.opacity(0.22) : Color.white.opacity(0.07),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isCurrent ? Color.lqGold : Color.clear, lineWidth: 3)
        )
        .accessibilityElement(children: .combine)
    }
}
