import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarProgressService {
  static const String _progressKey = 'adhkar_progress';
  static const String _itemProgressKey = 'adhkar_item_progress';
  static const String _viewModeKey = 'adhkar_view_mode';

  // Get progress for a specific category
  Future<double> getProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString('${_progressKey}_$category');
    if (progressData != null) {
      return double.tryParse(progressData) ?? 0.0;
    }
    return 0.0;
  }

  // Save progress for a specific category
  Future<void> saveProgress(String category, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_progressKey}_$category', progress.toString());
  }

  // Get progress for a specific adhkar item
  Future<int> getItemProgress(int categoryId, int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_itemProgressKey}_${categoryId}_$itemId';
    return prefs.getInt(key) ?? 0;
  }

  // Save progress for a specific adhkar item
  Future<void> saveItemProgress(
      int categoryId, int itemId, int completedCount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_itemProgressKey}_${categoryId}_$itemId';
    await prefs.setInt(key, completedCount);
  }

  // Update progress when an adhkar item is completed
  Future<double> updateItemProgress(
      int categoryId, int itemId, int totalCount) async {
    final currentProgress = await getItemProgress(categoryId, itemId);
    final newProgress = currentProgress + 1;

    if (newProgress >= totalCount) {
      // Item completed
      await saveItemProgress(categoryId, itemId, totalCount);
    } else {
      // Item in progress
      await saveItemProgress(categoryId, itemId, newProgress);
    }

    // Calculate overall category progress
    return await calculateCategoryProgress(categoryId);
  }

  // Calculate overall progress for a category
  Future<double> calculateCategoryProgress(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final categoryKeys = keys
        .where((key) => key.startsWith('${_itemProgressKey}_${categoryId}_'));

    if (categoryKeys.isEmpty) return 0.0;

    double totalProgress = 0.0;
    int totalItems = 0;

    for (final key in categoryKeys) {
      final parts = key.split('_');
      if (parts.length >= 4) {
        final itemId = int.tryParse(parts.last) ?? 0;
        final progress = prefs.getInt(key) ?? 0;

        // We need to get the total count for this item from the category data
        // For now, we'll assume each item has a count of 1 (single completion)
        // This should be updated to get the actual count from the category model
        final totalCount = 1; // This should come from the actual item data

        if (totalCount > 0) {
          totalProgress += progress / totalCount;
          totalItems++;
        }
      }
    }

    return totalItems > 0 ? totalProgress / totalItems : 0.0;
  }

  // Calculate category progress with actual category data
  Future<double> calculateCategoryProgressWithData(
      List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return 0.0;

    double totalProgress = 0.0;
    int totalItems = items.length;

    for (final item in items) {
      final itemId = item['id'] as int;
      final count = item['count'] as int;
      final progress =
          await getItemProgress(0, itemId); // Using 0 as default categoryId

      if (count > 0) {
        totalProgress += progress / count;
      }
    }

    return totalItems > 0 ? totalProgress / totalItems : 0.0;
  }

  // Reset progress for a specific category
  Future<void> resetProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_progressKey}_$category');

    // Also reset all items in this category
    final keys = prefs.getKeys();
    final categoryKeys =
        keys.where((key) => key.startsWith('${_itemProgressKey}_'));
    for (final key in categoryKeys) {
      await prefs.remove(key);
    }
  }

  // Get saved view mode
  Future<String> getViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_viewModeKey) ?? 'list';
  }

  // Save view mode
  Future<void> saveViewMode(String viewMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewModeKey, viewMode);
  }

  // Get all progress data
  Future<Map<String, double>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final progressKeys = keys.where((key) => key.startsWith(_progressKey));

    Map<String, double> progress = {};
    for (final key in progressKeys) {
      final category = key.replaceFirst('${_progressKey}_', '');
      final value = prefs.getString(key);
      if (value != null) {
        progress[category] = double.tryParse(value) ?? 0.0;
      }
    }

    return progress;
  }

  // Get daily progress for streak tracking
  Future<Map<String, dynamic>> getDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_progress_$today';

    final data = prefs.getString(key);
    if (data != null) {
      return json.decode(data);
    }

    return {
      'date': today,
      'categories_completed': 0,
      'total_adhkar': 0,
      'streak_days': 0,
    };
  }

  // Save daily progress
  Future<void> saveDailyProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_progress_$today';

    await prefs.setString(key, json.encode(progress));
  }

  // Get last opened category
  Future<Map<String, dynamic>?> getLastOpenedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final category = prefs.getString('last_opened_category');
    final progress = prefs.getDouble('last_opened_progress') ?? 0.0;

    if (category != null) {
      return {
        'category': category,
        'progress': progress,
      };
    }
    return null;
  }

  // Save last opened category
  Future<void> saveLastOpenedCategory(String category, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_opened_category', category);
    await prefs.setDouble('last_opened_progress', progress);
  }

  // Update last opened category progress
  Future<void> updateLastOpenedProgress(double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_opened_progress', progress);
  }
}
