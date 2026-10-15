//
//  PauseMenuView.swift
//  LankaQuest
//

import SwiftUI

/// Shown when Play/Pause or Menu is pressed during the race. The timer stops while paused.
struct PauseMenuView: View {
    let engine: GameEngine
    let onMainMenu: () -> Void

    @FocusState private var resumeFocused: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(Color.lqGold)
                GradientTitle(text: "Paused", size: 64)

                Button { engine.isPaused = false } label: {
                    Label("Resume", systemImage: "play.fill")
                        .frame(width: 480)
                }
                .buttonStyle(.lqProminent)
                .focused($resumeFocused)

                Button { engine.finishEarly() } label: {
                    Label("End game and see results", systemImage: "trophy.fill")
                        .frame(width: 480)
                }
                .buttonStyle(.lq)

                Button(action: onMainMenu) {
                    Label("Quit to main menu", systemImage: "house.fill")
                        .frame(width: 480)
                }
                .buttonStyle(.lq)
            }
            .padding(30)
            .glassCard()
        }
        .onAppear { resumeFocused = true }
    }
}
