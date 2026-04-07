// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';
import '../utils/scores_repository.dart';

// ── Theme provider ─────────────────────────────────────────────────────────
final themeProvider = StateProvider<bool>((ref) => true); // true = dark

// ── Difficulty provider ────────────────────────────────────────────────────
final difficultyProvider =
    StateProvider<Difficulty>((ref) => Difficulty.beginner);

// ── Scores repository ──────────────────────────────────────────────────────
final scoresRepositoryProvider =
    Provider<ScoresRepository>((ref) => ScoresRepository());

final bestTimesProvider =
    FutureProvider<Map<Difficulty, int?>>((ref) async {
  return ref.read(scoresRepositoryProvider).getAllBestTimes();
});

// ── Game notifier ──────────────────────────────────────────────────────────
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(Difficulty difficulty)
      : super(GameState.initial(difficulty));

  Timer? _timer;
  final _repo = ScoresRepository();

  void newGame(Difficulty difficulty) {
    _timer?.cancel();
    state = GameState.initial(difficulty);
  }

  void restart() {
    _timer?.cancel();
    state = GameState.initial(state.difficulty);
  }

  void revealCell(int row, int col) {
    if (state.status == GameStatus.won ||
        state.status == GameStatus.lost) return;

    final cell = state.cell(row, col);
    if (cell.isRevealed || cell.isFlagged) return;

    var board = state.board;

    // First click: place mines then reveal
    if (state.firstClick) {
      board = GameLogic.placeMines(
        board,
        state.rows,
        state.cols,
        state.totalMines,
        row,
        col,
      );
      _startTimer();
      state = state.copyWith(board: board, firstClick: false,
          status: GameStatus.playing);
    }

    final updatedBoard = GameLogic.revealCell(
        state.board, state.rows, state.cols, row, col);

    if (updatedBoard == null) {
      // Hit a mine
      final blasted = GameLogic.revealAllMines(
          state.board, state.rows, state.cols);
      _timer?.cancel();
      state = state.copyWith(board: blasted, status: GameStatus.lost);
      return;
    }

    final won = GameLogic.checkWin(updatedBoard, state.rows, state.cols);
    if (won) {
      _timer?.cancel();
      _repo.saveBestTime(state.difficulty, state.elapsedSeconds);
    }

    state = state.copyWith(
      board: updatedBoard,
      status: won ? GameStatus.won : GameStatus.playing,
    );
  }

  void toggleFlag(int row, int col) {
    if (state.status == GameStatus.won ||
        state.status == GameStatus.lost) return;
    if (state.firstClick) return; // can't flag before first reveal

    final cell = state.cell(row, col);
    if (cell.isRevealed) return;

    final delta = cell.isFlagged ? -1 : 1;
    final newBoard = GameLogic.toggleFlag(
        state.board, state.rows, state.cols, row, col);
    state = state.copyWith(
      board: newBoard,
      flagsPlaced: state.flagsPlaced + delta,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final difficulty = ref.watch(difficultyProvider);
  return GameNotifier(difficulty);
});
