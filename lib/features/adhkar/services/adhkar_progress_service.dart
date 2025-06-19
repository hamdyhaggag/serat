import 'package:shared_preferences/shared_preferences.dart';

class AdhkarProgressService {
  static const String _progressKeyPrefix = 'adhkar_progress_';

  Future<void> saveProgress(String category, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_progressKeyPrefix$category', progress);
  }

  Future<double> getProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_progressKeyPrefix$category') ?? 0.0;
  }

  Future<void> resetProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_progressKeyPrefix$category');
  }
}
