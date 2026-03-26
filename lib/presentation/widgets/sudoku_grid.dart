// lib/presentation/widgets/sudoku_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    if (state == null) return const SizedBox.shrink();

    final selRow = state.selectedRow;
    final selCol = state.selectedCol;
    final selVal = (selRow != null && selCol != null)
        ? state.board[selRow][selCol].value
        : 0;

    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  final cell = state.board[row][col];
                  final isSelected = selRow == row && selCol == col;
                  final isHighlighted = selRow == row ||
                      selCol == col ||
                      (_sameBox(row, col, selRow, selCol));
                  final isSameValue =
                      selVal != 0 && cell.value == selVal && !isSelected;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectCell(row, col),
                      child: _CellWidget(
                        cell: cell,
                        isSelected: isSelected,
                        isHighlighted: isHighlighted,
                        isSameValue: isSameValue,
                        row: row,
                        col: col,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      );
  }

  bool _sameBox(int r1, int c1, int? r2, int? c2) {
    if (r2 == null || c2 == null) return false;
    return (r1 ~/ 3) == (r2 ~/ 3) && (c1 ~/ 3) == (c2 ~/ 3);
  }
}

class _CellWidget extends StatelessWidget {
  final dynamic cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isSameValue;
  final int row;
  final int col;

  const _CellWidget({
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.isSameValue,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.cellBackground(
      context,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isSameValue: isSameValue,
      isGiven: cell.isGiven,
      hasConflict: cell.hasConflict,
    );

    final textColor = AppTheme.cellTextColor(
      context,
      isSelected: isSelected,
      isGiven: cell.isGiven,
      hasConflict: cell.hasConflict,
    );

    // Border thickness based on box boundaries
    final borderRight = (col + 1) % 3 == 0 && col != 8 ? 2.0 : 0.5;
    final borderBottom = (row + 1) % 3 == 0 && row != 8 ? 2.0 : 0.5;
    final borderColor = Theme.of(context).colorScheme.primary.withOpacity(0.4);
    final thickBorderColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(
            color: (col + 1) % 3 == 0 && col != 8 ? thickBorderColor : borderColor,
            width: borderRight,
          ),
          bottom: BorderSide(
            color: (row + 1) % 3 == 0 && row != 8 ? thickBorderColor : borderColor,
            width: borderBottom,
          ),
        ),
      ),
      child: cell.value != 0
          ? Center(
              child: Text(
                '${cell.value}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight:
                      cell.isGiven ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )
          : cell.notes.isNotEmpty
              ? _NotesGrid(notes: cell.notes, isHighlighted: isHighlighted || isSelected)
              : null,
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  final bool isHighlighted;

  const _NotesGrid({required this.notes, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.45);
    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: List.generate(9, (i) {
          final n = i + 1;
          return Center(
            child: Text(
              notes.contains(n) ? '$n' : '',
              style: TextStyle(fontSize: 7, color: color, height: 1),
            ),
          );
        }),
      ),
    );
  }
}
