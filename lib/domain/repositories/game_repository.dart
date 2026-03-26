// lib/domain/repositories/game_repository.dart

import '../entities/game_state.dart';

abstract class GameRepository {
  Future<void> saveGame(GameState state);
  Future<GameState?> loadGame();
  Future<void> clearGame();
}
