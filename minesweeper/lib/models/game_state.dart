// lib/models/game_state.dart
import 'cell.dart';
import 'difficulty.dart';

enum GameStatus { idle, playing, won, lost }

class GameState {
  final List<List<Cell>> board;
  final Difficulty difficulty;
  final GameStatus status;
  final int flagsPlaced;
  final int elapsedSeconds;
  final bool firstClick;

  const GameState({
    required this.board,
    required this.difficulty,
    this.status = GameStatus.idle,
    this.flagsPlaced = 0,
    this.elapsedSeconds = 0,
    this.firstClick = true,
  });

  int get rows => difficulty.rows;
  int get cols => difficulty.cols;
  int get totalMines => difficulty.mines;
  int get minesRemaining => totalMines - flagsPlaced;

  Cell cell(int row, int col) => board[row][col];

  GameState copyWith({
    List<List<Cell>>? board,
    Difficulty? difficulty,
    GameStatus? status,
    int? flagsPlaced,
    int? elapsedSeconds,
    bool? firstClick,
  }) {
    return GameState(
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      flagsPlaced: flagsPlaced ?? this.flagsPlaced,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      firstClick: firstClick ?? this.firstClick,
    );
  }

  static GameState initial(Difficulty difficulty) {
    final board = List.generate(
      difficulty.rows,
      (r) => List.generate(
        difficulty.cols,
        (c) => Cell(row: r, col: c),
      ),
    );
    return GameState(board: board, difficulty: difficulty);
  }
}
