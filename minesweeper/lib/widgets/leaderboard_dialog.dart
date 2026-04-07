// lib/widgets/leaderboard_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/difficulty.dart';
import '../providers/game_provider.dart';

class LeaderboardDialog extends ConsumerWidget {
  const LeaderboardDialog({super.key});

  String _fmt(int? s) {
    if (s == null) return '--:--';
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTimes = ref.watch(bestTimesProvider);
    return AlertDialog(
      title: const Text('🏆 Best Times'),
      content: asyncTimes.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (times) => Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((d) {
            return ListTile(
              title: Text(d.label),
              trailing: Text(
                _fmt(times[d]),
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
