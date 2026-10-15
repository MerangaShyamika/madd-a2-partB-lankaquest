//
//  HowToPlayView.swift
//  LankaQuest
//

import SwiftUI

/// Four illustrated steps plus tips about the lifeline, streaks and pausing.
struct HowToPlayView: View {
    let onBack: () -> Void

    private let steps: [(icon: String, title: String, text: String)] = [
        ("person.3.fill", "Pick your players",
         "2 to 4 players. Choose an avatar and an age band: Kids, Teens or Adults."),
        ("questionmark.bubble.fill", "Answer your question",
         "Everyone gets questions made for their age, so the whole family has a fair chance."),
        ("map.fill", "Race around the island",
         "Each right answer moves you one province closer to Jaffna in the north."),
        ("trophy.fill", "Win the race",
         "First to the north wins, or the furthest player when the rounds run out.")
    ]

    var body: some View {
        VStack(spacing: 40) {
            GradientTitle(text: "How to play", size: 72)

            HStack(alignment: .top, spacing: 32) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(red: 1, green: 0.85, blue: 0.35), .orange],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(width: 110, height: 110)
                            Image(systemName: step.icon)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        Text("\(index + 1). \(step.title)")
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                        Text(step.text)
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 330, height: 360, alignment: .top)
                    .glassCard()
                }
            }

            HStack(spacing: 28) {
                tip(icon: "circle.lefthalf.filled", text: "50:50 lifeline removes two wrong answers, once per game")
                tip(icon: "flame.fill", text: "3 right in a row and every answer scores double")
                tip(icon: "playpause.fill", text: "Press Play/Pause any time to pause")
            }

            Button(action: onBack) {
                Label("Back to menu", systemImage: "chevron.left")
            }
            .buttonStyle(.lq)
        }
        .onExitCommand(perform: onBack)
    }

    private func tip(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(Color.lqGold)
            Text(text)
                .font(.callout)
                .frame(width: 330, alignment: .leading)
        }
        .glassCard()
    }
}
