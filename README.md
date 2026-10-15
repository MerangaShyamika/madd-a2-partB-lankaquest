# LankaQuest (tvOS)

SE4041 Assignment 2, Part B: an innovative prototype for Apple TV.

LankaQuest is a living-room family game. Two to four players race around a map of Sri Lanka's nine provinces by answering heritage, geography, culture, nature and sport questions. **Each player gets questions matched to their own age band**, so a grandparent and a nine-year-old can play together on the same TV and either can win.

## Requirements
- Mac with Xcode 16.x
- Apple TV simulator (Xcode > Settings > Components > tvOS), tvOS 17.0 or later

## Build and run
1. Open `LankaQuest.xcodeproj` in Xcode.
2. Choose an **Apple TV** simulator as the run destination.
3. Press **Cmd + R**. Run the unit tests with **Cmd + U**.

Simulator controls: arrow keys move focus, Return selects, Esc is Menu (back or pause).
For Play/Pause, open **Window > Show Apple TV Remote** in the Simulator.

## Screens
| Screen | What it does |
| --- | --- |
| Main menu | Play, How to play, Hall of Fame and Settings, over animated island art |
| How to play | Four illustrated steps plus tips |
| Settings | Rounds (5/10/15), answer timer (Relaxed/Normal/Quick), 50:50 lifeline on or off, streak bonus on or off, question categories |
| Player setup | 2–4 players, each with a name, avatar and age band. Remembers the family's players |
| Race board | Island map with the route, glowing reached provinces, pulsing current-player token, scoreboard with progress bars and streak flames |
| Question | Category chip, countdown ring, four focusable answer cards, 50:50 lifeline, result panel with points, province reached and a fun fact |
| Pause | Resume, end the game early, or quit to the menu |
| Results | Confetti, animated podium with a crown, highlights (sharpest mind, hottest streak), play again |
| Hall of Fame | Wins, games played and best score for every family member |

## Game rules
- A correct answer moves you one province and scores **10 points plus the seconds left**.
- With the streak bonus on, **three correct answers in a row** start scoring **double points** until you miss one.
- Each player has **one 50:50 lifeline** per game, which removes two wrong answers.
- The first player to reach Northern Province (Jaffna) wins, or the furthest along when the rounds run out (score breaks ties).

## tvOS features used
| Feature | Where |
| --- | --- |
| Multi-user, same-room play (pass the remote) | `GameEngine`, `GameBoardView` |
| Focus engine: card style, custom focus button style, programmatic focus | `LQButtonStyle`, `QuestionView`, menus |
| Siri Remote commands (Play/Pause, Menu) | `GameBoardView`, menu screens (`onExitCommand`) |
| 10-foot UI: large type, high contrast, glass panels | all views |
| Layered parallax app icon and Top Shelf images | `Assets.xcassets` |
| Saved players, settings and Hall of Fame | `PlayerStore`, `SettingsStore` |
| Animation: drifting background, token hops, pulse ring, countdown ring, podium, Canvas confetti | `Components.swift`, game views |

## Architecture
MVVM. `GameEngine` (an `@Observable` class) holds all the game rules, with no UI code, so it is unit-testable. The views read its state and call its methods.

```
LankaQuest/
  Models/     Player, Question, AgeBand, Province, Settings (categories, timer, options), Theme
  Engine/     GameEngine (rules), QuestionBank (no repeats, category filter), PlayerStore + SettingsStore
  Views/
    Components/  AnimatedBackground, GlassCard, LQButtonStyle, GradientTitle, AvatarBadge, ConfettiView…
    Menu/        MainMenuView, HowToPlayView, HallOfFameView, SettingsView
    Game/        PlayerSetupView, GameBoardView, IslandMapView, QuestionView, PauseMenuView, ResultsView
  Resources/  questions.json (45 questions)
LankaQuestTests/  24 unit tests
```

## Adding questions
Edit `LankaQuest/Resources/questions.json`. Each question needs a unique `id`, an `ageBand` (`kids`, `teens` or `adults`), a `category` (`Culture`, `History`, `Geography`, `Nature` or `Sport`), 4 `options`, an `answerIndex` from 0 to 3, and a `funFact`. The `testBundledQuestionsAreValid` test checks the file.

## Similar apps
- **The Jackbox Party Pack** (Apple TV): party games that use phones as controllers. It is English-only and not aimed at mixed ages or local culture.
- Other trivia and family games on the Apple TV App Store. See the concept write-up in the report.

LankaQuest's difference is age-adaptive fairness, Sri Lankan heritage content and no extra devices.

## Credits
- SF Symbols by Apple.
- The question content was written for this project. The facts are general knowledge and were checked against public sources.

