// lib/widgets/difficulty_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/difficulty.dart';
import '../providers/game_provider.dart';

class DifficultySelector extends ConsumerWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(difficultyProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Difficulty.values.map((d) {
        final selected = d == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(d.label),
            selected: selected,
            onSelected: (_) {
              ref.read(difficultyProvider.notifier).state = d;
              ref.read(gameProvider.notifier).newGame(d);
            },
          ),
        );
      }).toList(),
    );
  }
}
