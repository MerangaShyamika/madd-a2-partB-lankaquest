//
//  HallOfFameView.swift
//  LankaQuest
//

import SwiftUI

/// The family leaderboard: wins, games played and best score, saved on the Apple TV.
struct HallOfFameView: View {
    let onBack: () -> Void

    @State private var entries: [HallEntry] = []

    var body: some View {
        VStack(spacing: 36) {
            GradientTitle(text: "Hall of Fame", size: 72)

            if entries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "crown")
                        .font(.system(size: 90))
                        .foregroundStyle(Color.lqGold)
                    Text("No champions yet")
                        .font(.title2.bold())
                    Text("Finish a race to enter the Hall of Fame.")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(width: 900)
                .glassCard()
            } else {
                VStack(spacing: 14) {
                    HStack {
                        Text("Player")
                        Spacer()
                        Text("Wins").frame(width: 150)
                        Text("Games").frame(width: 150)
                        Text("Best score").frame(width: 200)
                    }
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 28)

                    ForEach(Array(entries.prefix(6).enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 20) {
                            rankBadge(index)
                            Text(entry.name)
                                .font(.title3.bold())
                            Spacer()
                            Text("\(entry.wins)").frame(width: 150)
                            Text("\(entry.games)").frame(width: 150)
                            Text("\(entry.bestScore)").frame(width: 200)
                        }
                        .font(.title3.monospacedDigit())
                        .padding(.vertical, -8)
                        .glassCard(highlighted: index == 0)
                    }
                }
                .frame(width: 1300)
            }

            Button(action: onBack) {
                Label("Back to menu", systemImage: "chevron.left")
            }
            .buttonStyle(.lq)
        }
        .onAppear { entries = PlayerStore.hallOfFame() }
        .onExitCommand(perform: onBack)
    }

    @ViewBuilder
    private func rankBadge(_ index: Int) -> some View {
        if index == 0 {
            Image(systemName: "crown.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.lqGold)
                .frame(width: 60)
        } else {
            Text("\(index + 1)")
                .font(.title3.bold())
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.12), in: Circle())
                .frame(width: 60)
        }
    }
}
