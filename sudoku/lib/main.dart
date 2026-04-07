// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/game_repository_impl.dart';
import 'domain/repositories/game_repository.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        Provider<GameRepository>(
          create: (_) => GameRepositoryImpl(),
        ),
        ChangeNotifierProxyProvider<GameRepository, GameProvider>(
          create: (ctx) =>
              GameProvider(ctx.read<GameRepository>()),
          update: (ctx, repo, prev) => prev ?? GameProvider(repo),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title: 'Sudoku',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          home: const GameScreen(),
        ),
      ),
    );
  }
}
