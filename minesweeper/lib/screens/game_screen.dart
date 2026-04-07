// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/board_widget.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/hud_widget.dart';
import '../widgets/leaderboard_dialog.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MINESWEEPER',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Best Times',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const LeaderboardDialog(),
            ),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: () =>
                ref.read(themeProvider.notifier).state = !isDark,
          ),
        ],
      ),
      body: GameOverListener(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const DifficultySelector(),
                const SizedBox(height: 12),
                const HudWidget(),
                const SizedBox(height: 12),
                const Expanded(child: BoardWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
