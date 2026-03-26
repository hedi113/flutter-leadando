// lib/presentation/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/win_overlay.dart';
import '../../domain/entities/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event, GameProvider provider) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    final key = event.logicalKey;

    // Digits 1-9
    final digitKeys = {
      LogicalKeyboardKey.digit1: 1,
      LogicalKeyboardKey.digit2: 2,
      LogicalKeyboardKey.digit3: 3,
      LogicalKeyboardKey.digit4: 4,
      LogicalKeyboardKey.digit5: 5,
      LogicalKeyboardKey.digit6: 6,
      LogicalKeyboardKey.digit7: 7,
      LogicalKeyboardKey.digit8: 8,
      LogicalKeyboardKey.digit9: 9,
      LogicalKeyboardKey.numpad1: 1,
      LogicalKeyboardKey.numpad2: 2,
      LogicalKeyboardKey.numpad3: 3,
      LogicalKeyboardKey.numpad4: 4,
      LogicalKeyboardKey.numpad5: 5,
      LogicalKeyboardKey.numpad6: 6,
      LogicalKeyboardKey.numpad7: 7,
      LogicalKeyboardKey.numpad8: 8,
      LogicalKeyboardKey.numpad9: 9,
    };

    if (digitKeys.containsKey(key)) {
      provider.enterDigit(digitKeys[key]!);
      return;
    }

    // Erase
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0) {
      provider.eraseCell();
      return;
    }

    // Arrow key navigation
    final state = provider.state;
    if (state == null) return;
    int row = state.selectedRow ?? 4;
    int col = state.selectedCol ?? 4;

    if (key == LogicalKeyboardKey.arrowUp) row = (row - 1).clamp(0, 8);
    else if (key == LogicalKeyboardKey.arrowDown) row = (row + 1).clamp(0, 8);
    else if (key == LogicalKeyboardKey.arrowLeft) col = (col - 1).clamp(0, 8);
    else if (key == LogicalKeyboardKey.arrowRight) col = (col + 1).clamp(0, 8);
    else return;

    provider.selectCell(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.state == null) {
      return const _StartScreen();
    }

    final state = provider.state!;
    final isDark = themeProvider.isDark(context);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (e) => _handleKey(e, provider),
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(context, state, provider),
          actions: [
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggle(),
            ),
            IconButton(
              tooltip: 'New game',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showNewGameDialog(context, provider),
            ),
            IconButton(
              tooltip: 'Check puzzle',
              icon: const Icon(Icons.check_circle_outline_rounded),
              onPressed: () => _handleCheck(context, provider, state),
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Constrain the game area so it always fits on screen
                  final availH = constraints.maxHeight;
                  final availW = constraints.maxWidth;

                  // Number pad needs ~130px, badge ~40px, paddings ~40px
                  final maxGridSize = (availH - 220).clamp(200.0, availW - 20);
                  final gridSize = maxGridSize < availW - 20
                      ? maxGridSize
                      : availW - 20.0;

                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 4),
                              _DifficultyBadge(difficulty: state.difficulty),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: gridSize,
                                height: gridSize,
                                child: const SudokuGrid(),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: gridSize,
                                child: const NumberPad(),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (state.status == GameStatus.checking)
              _CheckingBanner(isCorrect: state.isCorrect && state.isComplete),
            if (state.status == GameStatus.won)
              WinOverlay(
                elapsedSeconds: state.elapsedSeconds,
                difficulty: state.difficulty,
              ),
            if (state.status == GameStatus.paused)
              _PausedOverlay(onResume: () => provider.resumeGame()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(
      BuildContext context, GameState state, GameProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Sudoku'),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => state.status == GameStatus.playing
              ? provider.pauseGame()
              : provider.resumeGame(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.status == GameStatus.paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.formatTime(state.elapsedSeconds),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNewGameDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Game'),
        content: const Text('Choose difficulty:'),
        actions: [
          ...Difficulty.values.map((d) {
            final label = d.name[0].toUpperCase() + d.name.substring(1);
            return TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                provider.newGame(d);
              },
              child: Text(label),
            );
          }),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleCheck(
      BuildContext context, GameProvider provider, GameState state) {
    if (!state.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill in all cells before checking!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    provider.checkBoard();
  }
}

class _StartScreen extends StatelessWidget {
  const _StartScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () => themeProvider.toggle(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧩',
                  style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              Text(
                'Sudoku',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Train your brain',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 48),
              ...Difficulty.values.map((d) {
                final label = d.name[0].toUpperCase() + d.name.substring(1);
                final subtitle = {
                  Difficulty.easy: '36–41 clues',
                  Difficulty.medium: '27–32 clues',
                  Difficulty.hard: '22–26 clues',
                }[d]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton(
                    onPressed: () => provider.newGame(d),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      backgroundColor: d == Difficulty.easy
                          ? Colors.green.shade600
                          : d == Difficulty.medium
                              ? cs.primary
                              : Colors.deepOrange.shade600,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(subtitle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = difficulty == Difficulty.easy
        ? Colors.green
        : difficulty == Difficulty.medium
            ? Theme.of(context).colorScheme.primary
            : Colors.deepOrange;
    final label =
        difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
    return Chip(
      label: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _CheckingBanner extends StatelessWidget {
  final bool isCorrect;
  const _CheckingBanner({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '✨ Perfect! All correct!' : '❌ Some cells are wrong',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  final VoidCallback onResume;
  const _PausedOverlay({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded,
                  color: Colors.white, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Paused',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to resume',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
