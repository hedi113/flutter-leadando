# 💣 Minesweeper — Flutter

A fully-featured Minesweeper game built with Flutter, Riverpod, and clean architecture.

## Features

| Feature | Status |
|---|---|
| Classic Minesweeper gameplay | ✅ |
| Beginner / Intermediate / Expert difficulty | ✅ |
| First-click safety (never die on first tap) | ✅ |
| Flood-fill auto-reveal for empty cells | ✅ |
| Long-press to flag / unflag | ✅ |
| Haptic feedback on flag | ✅ |
| Mine counter + timer HUD | ✅ |
| Win / Loss dialog with restart | ✅ |
| Animated cell reveals | ✅ |
| Dark / Light theme toggle | ✅ |
| Best-time leaderboard (shared_preferences) | ✅ |
| Riverpod state management | ✅ |
| Game logic fully decoupled from UI | ✅ |
| Unit tests for core logic | ✅ |

## Project Structure

```
lib/
├── main.dart                     # App entry, theming
├── models/
│   ├── cell.dart                 # Cell data class
│   ├── difficulty.dart           # Difficulty enum (rows/cols/mines)
│   └── game_state.dart           # Immutable game state
├── providers/
│   └── game_provider.dart        # Riverpod notifier + timer + theme
├── utils/
│   ├── game_logic.dart           # Pure Dart game logic (no Flutter)
│   └── scores_repository.dart    # SharedPreferences persistence
├── widgets/
│   ├── board_widget.dart         # Grid renderer
│   ├── cell_widget.dart          # Individual cell with animations
│   ├── difficulty_selector.dart  # Chip-based difficulty picker
│   ├── game_over_dialog.dart     # Win/loss listener + dialog
│   ├── hud_widget.dart           # Mine counter, timer, face button
│   └── leaderboard_dialog.dart   # Best times per difficulty
└── screens/
    └── game_screen.dart          # Main scaffold
test/
└── game_logic_test.dart          # Unit tests (no Flutter required)
```

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Dart ≥ 3.0

### Install & run

```bash
# Get dependencies
flutter pub get

# Run on a device / emulator
flutter run

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

## Architecture

- **Models** — pure immutable Dart data classes, no Flutter imports
- **`GameLogic`** — static methods only; easily unit-testable
- **`GameNotifier`** — Riverpod `StateNotifier` handles user actions, timer, win/loss detection
- **Providers** — theme, difficulty, game state, and async best-times all exposed via Riverpod
- **Widgets** — stateless/consumer widgets that read from providers; no business logic

## Controls

| Action | Mobile | Desktop/Web |
|---|---|---|
| Reveal cell | Tap | Left click |
| Flag / unflag | Long press | Right click (web) |
| Restart | Tap 🙂 face | Tap 🙂 face |
| Change difficulty | Tap chip | Tap chip |
