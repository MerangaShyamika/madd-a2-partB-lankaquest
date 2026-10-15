//
//  RootView.swift
//  LankaQuest
//

import SwiftUI

/// The screens reachable from the main menu.
enum AppScreen: Hashable {
    case menu, howToPlay, hallOfFame, settings, game
}

/// Switches between the menu screens and the game (setup, race, results).
struct RootView: View {
    @State private var engine = GameEngine()
    @State private var screen: AppScreen = .menu
    @State private var settings = SettingsStore.load()

    var body: some View {
        ZStack {
            AnimatedBackground()
            content
        }
        .animation(.easeInOut(duration: 0.45), value: screen)
        .animation(.easeInOut(duration: 0.45), value: engine.phase)
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .menu:
            MainMenuView { screen = $0 }
                .transition(.opacity)
        case .howToPlay:
            HowToPlayView { screen = .menu }
                .transition(.opacity)
        case .hallOfFame:
            HallOfFameView { screen = .menu }
                .transition(.opacity)
        case .settings:
            SettingsView(settings: $settings) {
                SettingsStore.save(settings)
                screen = .menu
            }
            .transition(.opacity)
        case .game:
            gameContent
        }
    }

    @ViewBuilder
    private var gameContent: some View {
        switch engine.phase {
        case .setup:
            PlayerSetupView(engine: engine, settings: settings) { screen = .menu }
                .transition(.opacity)
        case .playing:
            GameBoardView(engine: engine, onMainMenu: goToMenu)
                .transition(.opacity)
        case .finished:
            ResultsView(engine: engine, onMainMenu: goToMenu)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    private func goToMenu() {
        engine.newGame()
        screen = .menu
    }
}

#Preview {
    RootView()
}
