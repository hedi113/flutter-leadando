// lib/domain/entities/sudoku_cell.dart

class SudokuCell {
  final int row;
  final int col;
  int value; // 0 = empty
  bool isGiven; // pre-filled by puzzle
  bool hasConflict;
  Set<int> notes; // pencil marks

  SudokuCell({
    required this.row,
    required this.col,
    this.value = 0,
    this.isGiven = false,
    this.hasConflict = false,
    Set<int>? notes,
  }) : notes = notes ?? {};

  SudokuCell copyWith({
    int? value,
    bool? isGiven,
    bool? hasConflict,
    Set<int>? notes,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      value: value ?? this.value,
      isGiven: isGiven ?? this.isGiven,
      hasConflict: hasConflict ?? this.hasConflict,
      notes: notes ?? Set.from(this.notes),
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'value': value,
        'isGiven': isGiven,
        'hasConflict': hasConflict,
        'notes': notes.toList(),
      };

  factory SudokuCell.fromJson(Map<String, dynamic> json) => SudokuCell(
        row: json['row'],
        col: json['col'],
        value: json['value'],
        isGiven: json['isGiven'],
        hasConflict: json['hasConflict'] ?? false,
        notes: Set<int>.from(json['notes'] ?? []),
      );
}
