//
//  MainMenuView.swift
//  LankaQuest
//

import SwiftUI

/// Title screen: island artwork on the left, menu on the right.
struct MainMenuView: View {
    let onSelect: (AppScreen) -> Void

    @FocusState private var playFocused: Bool

    var body: some View {
        HStack(spacing: 110) {
            IslandMapView(players: [], showLabels: false)
                .frame(width: 520)

            VStack(alignment: .leading, spacing: 26) {
                GradientTitle(text: "LankaQuest", size: 110)
                Text("A family race around Sri Lanka.\nEveryone gets questions for their age.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))

                VStack(alignment: .leading, spacing: 22) {
                    Button { onSelect(.game) } label: {
                        Label("Play", systemImage: "play.fill")
                            .frame(width: 440, alignment: .leading)
                    }
                    .buttonStyle(.lqProminent)
                    .focused($playFocused)

                    menuButton("How to play", icon: "questionmark.circle.fill", screen: .howToPlay)
                    menuButton("Hall of Fame", icon: "crown.fill", screen: .hallOfFame)
                    menuButton("Settings", icon: "slider.horizontal.3", screen: .settings)
                }
                .padding(.top, 16)
            }
        }
        .onAppear { playFocused = true }
    }

    private func menuButton(_ title: String, icon: String, screen: AppScreen) -> some View {
        Button { onSelect(screen) } label: {
            Label(title, systemImage: icon)
                .frame(width: 440, alignment: .leading)
        }
        .buttonStyle(.lq)
    }
}
