// lib/presentation/providers/game_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/sudoku_cell.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/sudoku_generator.dart';

class GameProvider extends ChangeNotifier with WidgetsBindingObserver {
  final GameRepository _repository;
  final SudokuGenerator _generator = SudokuGenerator();

  GameState? _state;
  Timer? _timer;
  bool _isLoading = true;

  GameProvider(this._repository) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  GameState? get state => _state;
  bool get isLoading => _isLoading;
  bool get notesMode => _state?.notesMode ?? false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pauseTimer();
      _save();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ── Public actions ───────────────────────────────────────────────────────

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    final saved = await _repository.loadGame();
    if (saved != null && saved.status != GameStatus.won) {
      _state = saved;
      if (_state!.status == GameStatus.playing) _startTimer();
    }
    _isLoading = false;
    notifyListeners();
  }

  void newGame(Difficulty difficulty) {
    _timer?.cancel();
    _state = _generator.generateGame(difficulty);
    _startTimer();
    _save();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    if (_state == null) return;
    if (_state!.board[row][col].isGiven) {
      // Selecting a given cell deselects
      if (_state!.selectedRow == row && _state!.selectedCol == col) {
        _state!.selectedRow = null;
        _state!.selectedCol = null;
      } else {
        _state!.selectedRow = row;
        _state!.selectedCol = col;
      }
    } else {
      _state!.selectedRow = row;
      _state!.selectedCol = col;
    }
    notifyListeners();
  }

  void enterDigit(int digit) {
    final s = _state;
    if (s == null) return;
    final row = s.selectedRow;
    final col = s.selectedCol;
    if (row == null || col == null) return;
    final cell = s.board[row][col];
    if (cell.isGiven) return;

    if (s.notesMode) {
      // Toggle note
      final oldNotes = Set<int>.from(cell.notes);
      final newNotes = Set<int>.from(cell.notes);
      if (newNotes.contains(digit)) {
        newNotes.remove(digit);
      } else {
        newNotes.add(digit);
      }
      _recordAndApply(
        row, col,
        oldValue: cell.value,
        newValue: cell.value,
        oldNotes: oldNotes,
        newNotes: newNotes,
      );
    } else {
      final oldValue = cell.value;
      final newValue = oldValue == digit ? 0 : digit;
      _recordAndApply(
        row, col,
        oldValue: oldValue,
        newValue: newValue,
        oldNotes: Set.from(cell.notes),
        newNotes: {},
      );
    }

    _validateConflicts();
    _checkWin();
    _save();
    notifyListeners();
  }

  void eraseCell() {
    final s = _state;
    if (s == null) return;
    final row = s.selectedRow;
    final col = s.selectedCol;
    if (row == null || col == null) return;
    final cell = s.board[row][col];
    if (cell.isGiven) return;

    _recordAndApply(
      row, col,
      oldValue: cell.value,
      newValue: 0,
      oldNotes: Set.from(cell.notes),
      newNotes: {},
    );

    _validateConflicts();
    _save();
    notifyListeners();
  }

  void undo() {
    final s = _state;
    if (s == null || !s.canUndo) return;
    final move = s.history[s.historyIndex];
    s.board[move.row][move.col].value = move.oldValue;
    s.board[move.row][move.col].notes = Set.from(move.oldNotes);
    s.historyIndex--;
    _validateConflicts();
    _save();
    notifyListeners();
  }

  void redo() {
    final s = _state;
    if (s == null || !s.canRedo) return;
    s.historyIndex++;
    final move = s.history[s.historyIndex];
    s.board[move.row][move.col].value = move.newValue;
    s.board[move.row][move.col].notes = Set.from(move.newNotes);
    _validateConflicts();
    _save();
    notifyListeners();
  }

  void toggleNotesMode() {
    if (_state == null) return;
    _state!.notesMode = !_state!.notesMode;
    notifyListeners();
  }

  void checkBoard() {
    final s = _state;
    if (s == null) return;
    s.status = GameStatus.checking;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      if (_state?.status == GameStatus.checking) {
        _state!.status = GameStatus.playing;
        notifyListeners();
      }
    });
  }

  void dismissWin() {
    if (_state == null) return;
    _state!.status = GameStatus.playing;
    notifyListeners();
  }

  void pauseGame() {
    if (_state?.status != GameStatus.playing) return;
    _state!.status = GameStatus.paused;
    _pauseTimer();
    _save();
    notifyListeners();
  }

  void resumeGame() {
    if (_state?.status != GameStatus.paused) return;
    _state!.status = GameStatus.playing;
    _resumeTimer();
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  void _recordAndApply(
    int row,
    int col, {
    required int oldValue,
    required int newValue,
    required Set<int> oldNotes,
    required Set<int> newNotes,
  }) {
    final s = _state!;
    // Truncate redo stack
    if (s.historyIndex < s.history.length - 1) {
      s.history.removeRange(s.historyIndex + 1, s.history.length);
    }
    s.history.add(MoveRecord(
      row: row,
      col: col,
      oldValue: oldValue,
      newValue: newValue,
      oldNotes: oldNotes,
      newNotes: newNotes,
    ));
    s.historyIndex = s.history.length - 1;
    s.board[row][col].value = newValue;
    s.board[row][col].notes = newNotes;
  }

  void _validateConflicts() {
    final s = _state;
    if (s == null) return;
    // Clear
    for (var row in s.board) {
      for (var cell in row) {
        cell.hasConflict = false;
      }
    }
    // Check each filled cell
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = s.board[r][c].value;
        if (val == 0) continue;
        if (_hasConflict(s.board, r, c, val)) {
          s.board[r][c].hasConflict = true;
        }
      }
    }
  }

  bool _hasConflict(List<List<SudokuCell>> board, int row, int col, int val) {
    // Row
    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c].value == val) return true;
    }
    // Column
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col].value == val) return true;
    }
    // Box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && board[r][c].value == val) return true;
      }
    }
    return false;
  }

  void _checkWin() {
    final s = _state;
    if (s == null) return;
    if (s.isComplete && s.isCorrect) {
      _pauseTimer();
      s.status = GameStatus.won;
      _repository.clearGame();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state?.status == GameStatus.playing) {
        _state!.elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void _pauseTimer() => _timer?.cancel();

  void _resumeTimer() => _startTimer();

  Future<void> _save() async {
    if (_state != null) await _repository.saveGame(_state!);
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
