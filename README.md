# 🧩 Flutter Sudoku Game

A fully-featured Sudoku game built with Flutter following clean architecture principles.

## Features

| Feature | Details |
|---|---|
| **Puzzle Generation** | Valid 9×9 puzzles with guaranteed unique solutions |
| **Difficulty Levels** | Easy (36–41 clues), Medium (27–32), Hard (22–26) |
| **Grid Highlighting** | Selected cell, row, column, and 3×3 box highlighted |
| **Same-Value Highlight** | All cells with the same digit are highlighted |
| **Number Pad** | On-screen 1–9 pad + Erase button |
| **Notes Mode** | Pencil-mark toggle per cell (3×3 mini-grid) |
| **Conflict Detection** | Real-time red highlight for duplicate digits |
| **Check Button** | Validates the full board with a banner |
| **Win Screen** | Animated overlay with time + difficulty on completion |
| **Undo / Redo** | Full move history with branching on new moves |
| **Timer** | MM:SS counter that pauses when app is backgrounded |
| **Pause / Resume** | Tap the timer chip in the app bar |
| **State Persistence** | Game auto-saved via `SharedPreferences` |
| **Theming** | Light & dark modes, toggle button in app bar |

---

## Architecture

```
lib/
├── main.dart                         # App entry + DI wiring
│
├── domain/                           # Pure Dart — no Flutter deps
│   ├── entities/
│   │   ├── sudoku_cell.dart          # Cell model (value, notes, flags)
│   │   └── game_state.dart          # Board, solution, history, status
│   ├── repositories/
│   │   └── game_repository.dart     # Abstract persistence contract
│   └── usecases/
│       └── sudoku_generator.dart    # Backtracking generator + solver
│
├── data/                             # Infrastructure
│   └── repositories/
│       └── game_repository_impl.dart # SharedPreferences implementation
│
└── presentation/                     # Flutter UI
    ├── providers/
    │   ├── game_provider.dart        # Business logic + ChangeNotifier
    │   └── theme_provider.dart      # Light/dark toggle + persistence
    ├── screens/
    │   └── game_screen.dart         # Main screen + start screen
    ├── theme/
    │   └── app_theme.dart           # Material 3 themes + cell colours
    └── widgets/
        ├── sudoku_grid.dart         # 9×9 grid with cell rendering
        ├── number_pad.dart          # Digit buttons + action buttons
        └── win_overlay.dart         # Animated win dialog
```

---

## Getting Started

### Prerequisites
- Flutter ≥ 3.10 (Dart ≥ 3.0)
- `flutter doctor` passes

### Run

```bash
cd sudoku_game
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release
```

### Build for iOS

```bash
flutter build ios --release
```

---

## Dependencies

```yaml
provider: ^6.1.1           # State management
shared_preferences: ^2.2.2 # Local persistence
```

---

## Key Design Decisions

### Puzzle Generation
Uses a two-phase algorithm:
1. **Fill phase**: Recursive backtracking with shuffled digit order to produce a random fully-solved grid.
2. **Remove phase**: Iterates shuffled positions, removes a digit, verifies the remaining puzzle still has exactly one solution (by counting with early exit at 2), and keeps the removal only if so. This guarantees uniqueness.

### Conflict Detection
After every move, the entire board is re-scanned. A cell is flagged `hasConflict = true` if its non-zero value appears elsewhere in the same row, column, or 3×3 box.

### Undo / Redo
Every user action (digit entry, erase, note toggle) appends a `MoveRecord` to `history` and advances `historyIndex`. Undo decrements the index and restores old values; redo increments it. Any new move truncates the redo stack (standard linear undo model).

### Timer & Lifecycle
A `WidgetsBindingObserver` pauses the `Timer` when the app transitions to `paused`/`inactive` and resumes it on `resumed`. The game is persisted to `SharedPreferences` on every pause.

---

## Screenshots

| Start Screen | Light Mode | Dark Mode |
|---|---|---|
| Difficulty picker | Puzzle with highlights | Same puzzle, dark theme |

---

## License

MIT
