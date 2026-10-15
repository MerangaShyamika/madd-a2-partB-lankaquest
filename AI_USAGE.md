# AI-assisted development log (Part B)

| Date | Tool | Prompt (summary) | What the AI produced | How I used or changed it |
| --- | --- | --- | --- | --- |
| 2026-10-15 | Claude | Asked for a tvOS family quiz prototype (LankaQuest) as a complete Xcode project | Xcode project, models, GameEngine, QuestionBank, PlayerStore, views, 30 questions, unit tests, app icon and Top Shelf images, README | (Fill in: what you reviewed, tested or changed) |
| 2026-10-15 | Claude | "Make the UI more attractive and add more options" | Main menu, How to play, Settings (rounds, timer speed, lifeline, streak bonus, categories), Hall of Fame; animated background, glass panels, gold focus buttons, confetti; 50:50 lifeline and streak bonus rules; 15 more questions; 24 unit tests | (Fill in: what you reviewed, tested or changed) |

## Notes for the viva
- Explain the `GameEngine` rules: turns, rounds, scoring, the streak bonus, the 50:50 lifeline, the timer and pause.
- Explain tvOS focus: `@FocusState`, `.focused(_:equals:)`, `.buttonStyle(.card)`, and how `LQButtonStyle` reads `@Environment(\.isFocused)`.
- Explain why the game logic is separate from the views (MVVM, testability).
