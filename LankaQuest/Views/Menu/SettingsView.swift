//
//  SettingsView.swift
//  LankaQuest
//

import SwiftUI

/// Game options. Press a row to change its value; press a category to switch it on or off.
struct SettingsView: View {
    @Binding var settings: GameSettings
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            GradientTitle(text: "Settings", size: 66)

            VStack(spacing: 18) {
                settingRow("Rounds per game", value: "\(settings.rounds)", icon: "arrow.triangle.2.circlepath") {
                    settings.rounds = settings.nextRounds
                }
                settingRow("Answer timer", value: settings.timerSpeed.title, icon: "timer") {
                    settings.timerSpeed = settings.timerSpeed.next
                }
                settingRow("50:50 lifeline", value: settings.lifelinesEnabled ? "On" : "Off",
                           icon: "circle.lefthalf.filled") {
                    settings.lifelinesEnabled.toggle()
                }
                settingRow("Streak bonus (double points)", value: settings.streakBonusEnabled ? "On" : "Off",
                           icon: "flame.fill") {
                    settings.streakBonusEnabled.toggle()
                }
            }
            .frame(width: 1100)

            VStack(spacing: 14) {
                Text("Question categories (at least one)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 24) {
                    ForEach(QuestionCategory.allCases) { category in
                        categoryChip(category)
                    }
                }
            }

            Button(action: onBack) {
                Label("Save and go back", systemImage: "checkmark")
            }
            .buttonStyle(.lqProminent)
        }
        .onExitCommand(perform: onBack)
    }

    private func settingRow(_ title: String, value: String, icon: String,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 24) {
                Image(systemName: icon)
                    .frame(width: 50)
                Text(title)
                Spacer()
                Text(value)
                    .fontWeight(.heavy)
                Image(systemName: "chevron.right.circle.fill")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.lq)
        .accessibilityValue(value)
    }

    private func categoryChip(_ category: QuestionCategory) -> some View {
        let isOn = settings.categories.contains(category)
        return Button {
            if isOn {
                if settings.categories.count > 1 {
                    settings.categories.remove(category)
                }
            } else {
                settings.categories.insert(category)
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 44))
                Text(category.rawValue)
                    .font(.headline)
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .foregroundStyle(isOn ? Color.white : Color.white.opacity(0.45))
            .frame(width: 180, height: 170)
            .background(isOn ? category.color.opacity(0.6) : Color.white.opacity(0.06))
        }
        .buttonStyle(.card)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}
