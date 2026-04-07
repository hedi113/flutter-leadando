// lib/widgets/cell_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cell.dart';

class CellWidget extends StatefulWidget {
  final Cell cell;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool gameOver;

  const CellWidget({
    super.key,
    required this.cell,
    required this.size,
    required this.onTap,
    required this.onLongPress,
    this.gameOver = false,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );
  }

  @override
  void didUpdateWidget(CellWidget old) {
    super.didUpdateWidget(old);
    if (!old.cell.isRevealed && widget.cell.isRevealed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<Color> _numberColors = [
    Colors.transparent,
    Color(0xFF2196F3), // 1 blue
    Color(0xFF4CAF50), // 2 green
    Color(0xFFF44336), // 3 red
    Color(0xFF1A237E), // 4 dark blue
    Color(0xFF8B0000), // 5 dark red
    Color(0xFF00BCD4), // 6 cyan
    Color(0xFF212121), // 7 black
    Color(0xFF757575), // 8 grey
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cell = widget.cell;
    final s = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(1.0, _scaleAnim.value + (1 - _scaleAnim.value)),
            child: _buildCell(isDark, cell, s),
          );
        },
      ),
    );
  }

  Widget _buildCell(bool isDark, Cell cell, double s) {
    final baseColor = isDark ? const Color(0xFF2D3748) : const Color(0xFFBDBDBD);
    final revealedColor = isDark ? const Color(0xFF1A202C) : const Color(0xFFE0E0E0);
    final borderLight = isDark ? const Color(0xFF4A5568) : const Color(0xFFFFFFFF);
    final borderDark = isDark ? const Color(0xFF1A202C) : const Color(0xFF9E9E9E);

    if (!cell.isRevealed) {
      return Container(
        width: s,
        height: s,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: baseColor,
          border: Border(
            top: BorderSide(color: borderLight, width: 2),
            left: BorderSide(color: borderLight, width: 2),
            bottom: BorderSide(color: borderDark, width: 2),
            right: BorderSide(color: borderDark, width: 2),
          ),
        ),
        child: cell.isFlagged
            ? Center(
                child: Text('🚩',
                    style: TextStyle(fontSize: s * 0.55)))
            : null,
      );
    }

    // Revealed
    if (cell.isMine) {
      return Container(
        width: s,
        height: s,
        margin: const EdgeInsets.all(1),
        color: const Color(0xFFEF5350),
        child: Center(
          child: Text('💣', style: TextStyle(fontSize: s * 0.55)),
        ),
      );
    }

    return Container(
      width: s,
      height: s,
      margin: const EdgeInsets.all(1),
      color: revealedColor,
      child: cell.adjacentMines > 0
          ? Center(
              child: Text(
                '${cell.adjacentMines}',
                style: TextStyle(
                  fontSize: s * 0.6,
                  fontWeight: FontWeight.bold,
                  color: _numberColors[cell.adjacentMines],
                ),
              ),
            )
          : null,
    );
  }
}
