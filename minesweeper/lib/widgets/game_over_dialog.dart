// lib/widgets/game_over_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';

class GameOverListener extends ConsumerStatefulWidget {
  final Widget child;
  const GameOverListener({super.key, required this.child});

  @override
  ConsumerState<GameOverListener> createState() => _GameOverListenerState();
}

class _GameOverListenerState extends ConsumerState<GameOverListener> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameProvider, (prev, next) {
      if (prev?.status == next.status) return;
      if (next.status == GameStatus.won || next.status == GameStatus.lost) {
        if (!_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _showDialog(context, next);
          });
        }
      } else {
        _dialogShown = false;
      }
    });

    return widget.child;
  }

  void _showDialog(BuildContext context, GameState state) {
    final won = state.status == GameStatus.won;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(won ? '🎉 You Won!' : '💣 Boom!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won
                  ? 'Cleared in ${_fmt(state.elapsedSeconds)}!'
                  : 'Better luck next time.',
              textAlign: TextAlign.center,
            ),
            if (won) ...[
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${state.difficulty.label}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dialogShown = false;
              ref.read(gameProvider.notifier).restart();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '${m}m ${sec}s' : '${sec}s';
  }
}
