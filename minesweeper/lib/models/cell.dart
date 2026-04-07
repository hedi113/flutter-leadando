// lib/models/cell.dart
class Cell {
  final int row;
  final int col;
  final bool isMine;
  final bool isRevealed;
  final bool isFlagged;
  final int adjacentMines;

  const Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });

  Cell copyWith({
    bool? isMine,
    bool? isRevealed,
    bool? isFlagged,
    int? adjacentMines,
  }) {
    return Cell(
      row: row,
      col: col,
      isMine: isMine ?? this.isMine,
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
      adjacentMines: adjacentMines ?? this.adjacentMines,
    );
  }

  bool get isEmpty => !isMine && adjacentMines == 0;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}
