// lib/utils/scores_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty.dart';

class ScoresRepository {
  static const _prefix = 'best_time_';

  Future<int?> getBestTime(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${difficulty.name}';
    final value = prefs.getInt(key);
    return value;
  }

  Future<void> saveBestTime(Difficulty difficulty, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${difficulty.name}';
    final existing = prefs.getInt(key);
    if (existing == null || seconds < existing) {
      await prefs.setInt(key, seconds);
    }
  }

  Future<Map<Difficulty, int?>> getAllBestTimes() async {
    final result = <Difficulty, int?>{};
    for (final d in Difficulty.values) {
      result[d] = await getBestTime(d);
    }
    return result;
  }
}
