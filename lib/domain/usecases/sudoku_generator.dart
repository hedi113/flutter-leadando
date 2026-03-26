// lib/domain/usecases/sudoku_generator.dart

import 'dart:math';
import '../entities/sudoku_cell.dart';
import '../entities/game_state.dart';

class SudokuGenerator {
  final Random _random = Random();

  // ── Public API ───────────────────────────────────────────────────────────

  /// Returns a fully solved 9×9 grid.
  List<List<int>> generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  /// Returns [puzzle, solution] boards with [clues] cells pre-filled.
  GameState generateGame(Difficulty difficulty) {
    final solutionGrid = generateSolution();
    final puzzleGrid =
        List.generate(9, (r) => List.generate(9, (c) => solutionGrid[r][c]));

    final clues = _cluesFor(difficulty);
    _removeNumbers(puzzleGrid, 81 - clues);

    // Build cell models
    final board = List.generate(
      9,
      (r) => List.generate(
        9,
        (c) => SudokuCell(
          row: r,
          col: c,
          value: puzzleGrid[r][c],
          isGiven: puzzleGrid[r][c] != 0,
        ),
      ),
    );

    final solution = List.generate(
      9,
      (r) => List.generate(
        9,
        (c) => SudokuCell(
          row: r,
          col: c,
          value: solutionGrid[r][c],
          isGiven: true,
        ),
      ),
    );

    return GameState(board: board, solution: solution, difficulty: difficulty);
  }

  // ── Constraint helpers ───────────────────────────────────────────────────

  bool isSafe(List<List<int>> grid, int row, int col, int num) {
    // Row
    if (grid[row].contains(num)) return false;
    // Column
    if (grid.any((r) => r[col] == num)) return false;
    // Box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final num in nums) {
            if (isSafe(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  void _removeNumbers(List<List<int>> grid, int toRemove) {
    final positions = List.generate(81, (i) => i)..shuffle(_random);
    int removed = 0;

    for (final pos in positions) {
      if (removed >= toRemove) break;
      final row = pos ~/ 9;
      final col = pos % 9;
      if (grid[row][col] == 0) continue;

      final backup = grid[row][col];
      grid[row][col] = 0;

      // Verify unique solution
      final copy =
          List.generate(9, (r) => List.generate(9, (c) => grid[r][c]));
      if (_countSolutions(copy) == 1) {
        removed++;
      } else {
        grid[row][col] = backup;
      }
    }
  }

  /// Counts solutions up to 2 (we only care whether it's 0, 1, or ≥2).
  int _countSolutions(List<List<int>> grid, [int count = 0]) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isSafe(grid, row, col, num)) {
              grid[row][col] = num;
              count = _countSolutions(grid, count);
              if (count >= 2) return count;
              grid[row][col] = 0;
            }
          }
          return count;
        }
      }
    }
    return count + 1;
  }

  int _cluesFor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 36 + _random.nextInt(6); // 36-41
      case Difficulty.medium:
        return 27 + _random.nextInt(6); // 27-32
      case Difficulty.hard:
        return 22 + _random.nextInt(5); // 22-26
    }
  }
}
