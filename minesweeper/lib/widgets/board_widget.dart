// lib/widgets/board_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import 'cell_widget.dart';

class BoardWidget extends ConsumerWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameOver = gameState.status == GameStatus.won ||
        gameState.status == GameStatus.lost;

    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final maxH = constraints.maxHeight;
      final cellSize = (maxW / gameState.cols)
          .clamp(0.0, maxH / gameState.rows)
          .clamp(0.0, 40.0);

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gameState.rows, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(gameState.cols, (col) {
                  final cell = gameState.cell(row, col);
                  return CellWidget(
                    key: ValueKey('$row,$col'),
                    cell: cell,
                    size: cellSize,
                    gameOver: gameOver,
                    onTap: () => ref
                        .read(gameProvider.notifier)
                        .revealCell(row, col),
                    onLongPress: () => ref
                        .read(gameProvider.notifier)
                        .toggleFlag(row, col),
                  );
                }),
              );
            }),
          ),
        ),
      );
    });
  }
}
