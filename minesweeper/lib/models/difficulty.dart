// lib/models/difficulty.dart
enum Difficulty {
  beginner(rows: 9, cols: 9, mines: 10, label: 'Beginner'),
  intermediate(rows: 16, cols: 16, mines: 40, label: 'Intermediate'),
  expert(rows: 16, cols: 30, mines: 99, label: 'Expert');

  const Difficulty({
    required this.rows,
    required this.cols,
    required this.mines,
    required this.label,
  });

  final int rows;
  final int cols;
  final int mines;
  final String label;
}
