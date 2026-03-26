// lib/data/repositories/game_repository_impl.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  static const _key = 'sudoku_game_state';

  @override
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_key, json);
  }

  @override
  Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return null;
      return GameState.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
