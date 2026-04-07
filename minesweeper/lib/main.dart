// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const ProviderScope(child: MinesweeperApp()));
}

class MinesweeperApp extends ConsumerWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Minesweeper',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(isDark),
      home: const GameScreen(),
    );
  }

  ThemeData _buildTheme(bool isDark) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF171923) : const Color(0xFFE8E8E8),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A202C) : const Color(0xFFBDBDBD),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: const Color(0xFF2196F3),
        labelStyle: const TextStyle(fontFamily: 'monospace'),
        backgroundColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFCFCFCF),
      ),
      useMaterial3: true,
    );
  }
}
