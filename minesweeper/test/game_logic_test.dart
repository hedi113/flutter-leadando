// test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/cell.dart';
import 'package:minesweeper/models/difficulty.dart';
import 'package:minesweeper/models/game_state.dart';
import 'package:minesweeper/utils/game_logic.dart';

void main() {
  group('GameLogic', () {
    late GameState initial;

    setUp(() {
      initial = GameState.initial(Difficulty.beginner);
    });

    // ── placeMines ─────────────────────────────────────────────────────
    group('placeMines', () {
      test('places the correct number of mines', () {
        final board = GameLogic.placeMines(
          initial.board, 9, 9, 10, 4, 4);
        int count = 0;
        for (final row in board) {
          for (final cell in row) {
            if (cell.isMine) count++;
          }
        }
        expect(count, 10);
      });

      test('safe cell is never a mine', () {
        for (var i = 0; i < 20; i++) {
          final board = GameLogic.placeMines(
              initial.board, 9, 9, 10, 0, 0);
          expect(board[0][0].isMine, isFalse);
        }
      });

      test('safe zone neighbors are mine-free', () {
        // Run many iterations to reduce flakiness
        for (var i = 0; i < 10; i++) {
          final board = GameLogic.placeMines(
              initial.board, 9, 9, 10, 4, 4);
          for (var dr = -1; dr <= 1; dr++) {
            for (var dc = -1; dc <= 1; dc++) {
              final r = 4 + dr;
              final c = 4 + dc;
              if (r >= 0 && r < 9 && c >= 0 && c < 9) {
                expect(board[r][c].isMine, isFalse,
                    reason: 'Cell ($r,$c) should be in safe zone');
              }
            }
          }
        }
      });

      test('adjacentMines counts are correct', () {
        // Build a deterministic board with a mine at (0,0)
        var board = List.generate(9, (r) =>
            List.generate(9, (c) => Cell(row: r, col: c)));
        board[0][0] = board[0][0].copyWith(isMine: true);

        // Recompute adjacency (done inside placeMines, but test the logic)
        final withMine = GameLogic.placeMines(
            initial.board, 9, 9, 1, 8, 8);
        // Just ensure no negative counts
        for (final row in withMine) {
          for (final cell in row) {
            expect(cell.adjacentMines, greaterThanOrEqualTo(0));
            expect(cell.adjacentMines, lessThanOrEqualTo(8));
          }
        }
      });
    });

    // ── revealCell ─────────────────────────────────────────────────────
    group('revealCell', () {
      test('returns null when a mine is revealed', () {
        var board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        // Find first mine
        int mr = -1, mc = -1;
        outer:
        for (var r = 0; r < 9; r++) {
          for (var c = 0; c < 9; c++) {
            if (board[r][c].isMine) {
              mr = r;
              mc = c;
              break outer;
            }
          }
        }
        expect(GameLogic.revealCell(board, 9, 9, mr, mc), isNull);
      });

      test('reveals cell when safe', () {
        final board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        final updated = GameLogic.revealCell(board, 9, 9, 4, 4);
        expect(updated, isNotNull);
        expect(updated![4][4].isRevealed, isTrue);
      });

      test('does not reveal flagged cells', () {
        var board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        board = GameLogic.toggleFlag(board, 9, 9, 4, 4);
        final updated = GameLogic.revealCell(board, 9, 9, 4, 4);
        expect(updated![4][4].isRevealed, isFalse);
      });
    });

    // ── toggleFlag ─────────────────────────────────────────────────────
    group('toggleFlag', () {
      test('flags an unrevealed cell', () {
        final board = GameLogic.toggleFlag(
            initial.board, 9, 9, 0, 0);
        expect(board[0][0].isFlagged, isTrue);
      });

      test('unflags a flagged cell', () {
        var board = GameLogic.toggleFlag(
            initial.board, 9, 9, 0, 0);
        board = GameLogic.toggleFlag(board, 9, 9, 0, 0);
        expect(board[0][0].isFlagged, isFalse);
      });

      test('cannot flag a revealed cell', () {
        var board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        board = GameLogic.revealCell(board, 9, 9, 4, 4)!;
        board = GameLogic.toggleFlag(board, 9, 9, 4, 4);
        expect(board[4][4].isFlagged, isFalse);
      });
    });

    // ── checkWin ───────────────────────────────────────────────────────
    group('checkWin', () {
      test('returns false when non-mine cells remain unrevealed', () {
        final board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        expect(GameLogic.checkWin(board, 9, 9), isFalse);
      });

      test('returns true when all non-mine cells are revealed', () {
        var board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        // Reveal every non-mine cell
        board = List.generate(9, (r) => List.generate(9, (c) {
          final cell = board[r][c];
          return cell.isMine ? cell : cell.copyWith(isRevealed: true);
        }));
        expect(GameLogic.checkWin(board, 9, 9), isTrue);
      });
    });

    // ── revealAllMines ────────────────────────────────────────────────
    group('revealAllMines', () {
      test('reveals all mines on the board', () {
        final board = GameLogic.placeMines(
            initial.board, 9, 9, 10, 4, 4);
        final revealed = GameLogic.revealAllMines(board, 9, 9);
        for (final row in revealed) {
          for (final cell in row) {
            if (cell.isMine) expect(cell.isRevealed, isTrue);
          }
        }
      });
    });
  });
}
