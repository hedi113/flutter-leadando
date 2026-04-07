// lib/utils/game_logic.dart
import 'dart:math';
import '../models/cell.dart';
import '../models/game_state.dart';

class GameLogic {
  static const List<List<int>> _directions = [
    [-1, -1], [-1, 0], [-1, 1],
    [0,  -1],           [0,  1],
    [1,  -1], [1,  0],  [1,  1],
  ];

  /// Place mines on the board, guaranteeing [safeRow],[safeCol] and its
  /// neighbors are mine-free (first-click safety).
  static List<List<Cell>> placeMines(
    List<List<Cell>> board,
    int rows,
    int cols,
    int mineCount,
    int safeRow,
    int safeCol,
  ) {
    final safeZone = <String>{};
    for (final d in _directions) {
      final r = safeRow + d[0];
      final c = safeCol + d[1];
      if (_inBounds(r, c, rows, cols)) safeZone.add('$r,$c');
    }
    safeZone.add('$safeRow,$safeCol');

    final candidates = <String>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (!safeZone.contains('$r,$c')) candidates.add('$r,$c');
      }
    }

    candidates.shuffle(Random());
    final minePositions = candidates.take(mineCount).toSet();

    // Build board with mines
    var newBoard = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => board[r][c].copyWith(isMine: minePositions.contains('$r,$c')),
      ),
    );

    // Compute adjacentMines counts
    newBoard = List.generate(rows, (r) {
      return List.generate(cols, (c) {
        if (newBoard[r][c].isMine) return newBoard[r][c];
        int count = 0;
        for (final d in _directions) {
          final nr = r + d[0];
          final nc = c + d[1];
          if (_inBounds(nr, nc, rows, cols) && newBoard[nr][nc].isMine) {
            count++;
          }
        }
        return newBoard[r][c].copyWith(adjacentMines: count);
      });
    });

    return newBoard;
  }

  /// Reveal a cell. If empty, flood-fills all connected empty cells.
  /// Returns the updated board, or null if a mine was hit.
  static List<List<Cell>>? revealCell(
    List<List<Cell>> board,
    int rows,
    int cols,
    int row,
    int col,
  ) {
    final target = board[row][col];
    if (target.isRevealed || target.isFlagged) return board;
    if (target.isMine) return null; // explosion

    var newBoard = _copyBoard(board, rows, cols);
    _floodFill(newBoard, rows, cols, row, col);
    return newBoard;
  }

  static void _floodFill(
    List<List<Cell>> board,
    int rows,
    int cols,
    int row,
    int col,
  ) {
    final stack = <List<int>>[[row, col]];
    while (stack.isNotEmpty) {
      final pos = stack.removeLast();
      final r = pos[0];
      final c = pos[1];
      final cell = board[r][c];
      if (cell.isRevealed || cell.isFlagged || cell.isMine) continue;
      board[r][c] = cell.copyWith(isRevealed: true);
      if (cell.isEmpty) {
        for (final d in _directions) {
          final nr = r + d[0];
          final nc = c + d[1];
          if (_inBounds(nr, nc, rows, cols) && !board[nr][nc].isRevealed) {
            stack.add([nr, nc]);
          }
        }
      }
    }
  }

  /// Toggle flag on an unrevealed cell.
  static List<List<Cell>> toggleFlag(
    List<List<Cell>> board,
    int rows,
    int cols,
    int row,
    int col,
  ) {
    final cell = board[row][col];
    if (cell.isRevealed) return board;
    final newBoard = _copyBoard(board, rows, cols);
    newBoard[row][col] = cell.copyWith(isFlagged: !cell.isFlagged);
    return newBoard;
  }

  /// Reveal all mines (called on loss).
  static List<List<Cell>> revealAllMines(
    List<List<Cell>> board,
    int rows,
    int cols,
  ) {
    return List.generate(rows, (r) {
      return List.generate(cols, (c) {
        final cell = board[r][c];
        return cell.isMine ? cell.copyWith(isRevealed: true) : cell;
      });
    });
  }

  /// Check if the player has won.
  static bool checkWin(List<List<Cell>> board, int rows, int cols) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cell = board[r][c];
        if (!cell.isMine && !cell.isRevealed) return false;
      }
    }
    return true;
  }

  static List<List<Cell>> _copyBoard(
      List<List<Cell>> board, int rows, int cols) {
    return List.generate(rows, (r) => List.from(board[r]));
  }

  static bool _inBounds(int r, int c, int rows, int cols) =>
      r >= 0 && r < rows && c >= 0 && c < cols;
}
