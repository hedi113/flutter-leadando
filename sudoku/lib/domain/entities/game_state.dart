// lib/domain/entities/game_state.dart

import 'sudoku_cell.dart';

enum Difficulty { easy, medium, hard }

enum GameStatus { playing, paused, won, checking }

class MoveRecord {
  final int row;
  final int col;
  final int oldValue;
  final int newValue;
  final Set<int> oldNotes;
  final Set<int> newNotes;

  MoveRecord({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.newValue,
    required this.oldNotes,
    required this.newNotes,
  });

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'oldValue': oldValue,
        'newValue': newValue,
        'oldNotes': oldNotes.toList(),
        'newNotes': newNotes.toList(),
      };

  factory MoveRecord.fromJson(Map<String, dynamic> json) => MoveRecord(
        row: json['row'],
        col: json['col'],
        oldValue: json['oldValue'],
        newValue: json['newValue'],
        oldNotes: Set<int>.from(json['oldNotes'] ?? []),
        newNotes: Set<int>.from(json['newNotes'] ?? []),
      );
}

class GameState {
  final List<List<SudokuCell>> board;
  final List<List<SudokuCell>> solution;
  final Difficulty difficulty;
  GameStatus status;
  final List<MoveRecord> history;
  int historyIndex; // points to the last applied move (-1 = no moves)
  int elapsedSeconds;
  int? selectedRow;
  int? selectedCol;
  bool notesMode;

  GameState({
    required this.board,
    required this.solution,
    required this.difficulty,
    this.status = GameStatus.playing,
    List<MoveRecord>? history,
    this.historyIndex = -1,
    this.elapsedSeconds = 0,
    this.selectedRow,
    this.selectedCol,
    this.notesMode = false,
  }) : history = history ?? [];

  bool get isComplete {
    for (var row in board) {
      for (var cell in row) {
        if (cell.value == 0) return false;
      }
    }
    return true;
  }

  bool get isCorrect {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value != solution[r][c].value) return false;
      }
    }
    return true;
  }

  SudokuCell? get selectedCell {
    if (selectedRow == null || selectedCol == null) return null;
    return board[selectedRow!][selectedCol!];
  }

  bool get canUndo => historyIndex >= 0;
  bool get canRedo => historyIndex < history.length - 1;

  Map<String, dynamic> toJson() => {
        'board': board.map((r) => r.map((c) => c.toJson()).toList()).toList(),
        'solution':
            solution.map((r) => r.map((c) => c.toJson()).toList()).toList(),
        'difficulty': difficulty.index,
        'status': status.index,
        'history': history.map((m) => m.toJson()).toList(),
        'historyIndex': historyIndex,
        'elapsedSeconds': elapsedSeconds,
        'notesMode': notesMode,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final board = (json['board'] as List)
        .map((r) =>
            (r as List).map((c) => SudokuCell.fromJson(c)).toList())
        .toList();
    final solution = (json['solution'] as List)
        .map((r) =>
            (r as List).map((c) => SudokuCell.fromJson(c)).toList())
        .toList();
    return GameState(
      board: board,
      solution: solution,
      difficulty: Difficulty.values[json['difficulty']],
      status: GameStatus.values[json['status'] ?? 0],
      history: (json['history'] as List?)
              ?.map((m) => MoveRecord.fromJson(m))
              .toList() ??
          [],
      historyIndex: json['historyIndex'] ?? -1,
      elapsedSeconds: json['elapsedSeconds'] ?? 0,
      notesMode: json['notesMode'] ?? false,
    );
  }
}
