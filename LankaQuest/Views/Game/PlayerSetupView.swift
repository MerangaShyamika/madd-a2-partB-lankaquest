//
//  PlayerSetupView.swift
//  LankaQuest
//

import SwiftUI

/// Choose 2 to 4 players: name, avatar and age band. Remembers the family's last players.
struct PlayerSetupView: View {
    let engine: GameEngine
    let settings: GameSettings
    let onBack: () -> Void

    @State private var drafts: [Player] = []
    @State private var wins: [String: Int] = [:]

    private var validPlayers: [Player] {
        drafts.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private var canStart: Bool {
        validPlayers.count >= GameEngine.playerRange.lowerBound
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                GradientTitle(text: "Who's playing?", size: 66)
                Label(settings.summary, systemImage: "slider.horizontal.3")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(alignment: .top, spacing: 32) {
                ForEach(drafts) { player in
                    PlayerSlotCard(
                        player: binding(for: player.id),
                        wins: wins[player.name] ?? 0,
                        canRemove: drafts.count > GameEngine.playerRange.lowerBound
                    ) {
                        drafts.removeAll { $0.id == player.id }
                    }
                }

                if drafts.count < GameEngine.playerRange.upperBound {
                    Button(action: addPlayer) {
                        VStack(spacing: 18) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 80))
                            Text("Add player")
                                .font(.title3.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 480)
                        .background(Color.white.opacity(0.06))
                    }
                    .buttonStyle(.card)
                }
            }

            Button(action: startGame) {
                Label("Start the race", systemImage: "flag.checkered")
                    .padding(.horizontal, 30)
            }
            .buttonStyle(.lqProminent)
            .disabled(!canStart)

            Text(canStart ? "On your turn, the remote is passed to you" : "Add names for at least two players")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.6))
        }
        .onAppear(perform: loadSaved)
        .onExitCommand(perform: onBack)
    }

    /// A binding to one draft by id (safe when players are removed).
    private func binding(for id: Player.ID) -> Binding<Player> {
        Binding(
            get: { drafts.first { $0.id == id } ?? Player(name: "", avatar: .hare, ageBand: .adults) },
            set: { newValue in
                if let index = drafts.firstIndex(where: { $0.id == id }) {
                    drafts[index] = newValue
                }
            }
        )
    }

    private func addPlayer() {
        let used = Set(drafts.map(\.avatar))
        let avatar = Avatar.allCases.first { !used.contains($0) } ?? .hare
        drafts.append(Player(name: "", avatar: avatar, ageBand: .adults))
    }

    private func loadSaved() {
        wins = PlayerStore.wins()
        guard drafts.isEmpty else { return }
        let saved = PlayerStore.loadPlayers()
        drafts = saved.count >= GameEngine.playerRange.lowerBound
            ? Array(saved.prefix(GameEngine.playerRange.upperBound))
            : [Player(name: "", avatar: .hare, ageBand: .adults),
               Player(name: "", avatar: .tortoise, ageBand: .kids)]
    }

    private func startGame() {
        let players = validPlayers.map { player in
            var trimmed = player
            trimmed.name = player.name.trimmingCharacters(in: .whitespaces)
            return trimmed
        }
        PlayerStore.savePlayers(players)
        engine.start(with: players, settings: settings)
    }
}

/// One player's card: press the avatar or the age band to change them.
struct PlayerSlotCard: View {
    @Binding var player: Player
    let wins: Int
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Button {
                player.avatar = player.avatar.next
            } label: {
                AvatarBadge(avatar: player.avatar, size: 110)
                    .padding(14)
            }
            .buttonStyle(.card)
            .accessibilityLabel("Avatar \(player.avatar.title). Press to change.")

            TextField("Player name", text: $player.name)
                .frame(width: 290)

            Button {
                player.ageBand = player.ageBand.next
            } label: {
                Label(player.ageBand.title, systemImage: player.ageBand.icon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: 230)
            }
            .buttonStyle(.lq)
            .accessibilityHint("Press to change the question level")

            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(Color.lqGold)
                Text(wins == 1 ? "1 win" : "\(wins) wins")
            }
            .font(.callout)
            .foregroundStyle(.white.opacity(0.75))

            if canRemove {
                Button(action: onRemove) {
                    Label("Remove", systemImage: "xmark")
                }
                .buttonStyle(.lqCompact)
            }
        }
        .frame(width: 320)
        .glassCard()
    }
}
