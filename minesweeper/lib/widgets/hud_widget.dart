// lib/widgets/hud_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';

class HudWidget extends ConsumerWidget {
  const HudWidget({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1A202C) : const Color(0xFFBDBDBD);
    final textColor = isDark ? const Color(0xFFFC3D21) : const Color(0xFFCC0000);
    final borderLight = isDark ? const Color(0xFF4A5568) : const Color(0xFFFFFFFF);
    final borderDark = isDark ? const Color(0xFF0D1117) : const Color(0xFF9E9E9E);

    String faceEmoji;
    switch (game.status) {
      case GameStatus.won:
        faceEmoji = '😎';
        break;
      case GameStatus.lost:
        faceEmoji = '😵';
        break;
      default:
        faceEmoji = '🙂';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderLight, width: 3),
          left: BorderSide(color: borderLight, width: 3),
          bottom: BorderSide(color: borderDark, width: 3),
          right: BorderSide(color: borderDark, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine counter
          _DigitalDisplay(
            value: game.minesRemaining.toString().padLeft(3, '0'),
            color: textColor,
          ),

          // Restart face button
          GestureDetector(
            onTap: () => ref.read(gameProvider.notifier).restart(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: borderLight, width: 2),
                  left: BorderSide(color: borderLight, width: 2),
                  bottom: BorderSide(color: borderDark, width: 2),
                  right: BorderSide(color: borderDark, width: 2),
                ),
              ),
              child: Text(faceEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),

          // Timer
          _DigitalDisplay(
            value: _formatTime(game.elapsedSeconds),
            color: textColor,
          ),
        ],
      ),
    );
  }
}

class _DigitalDisplay extends StatelessWidget {
  final String value;
  final Color color;

  const _DigitalDisplay({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: Colors.black,
      child: Text(
        value,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
