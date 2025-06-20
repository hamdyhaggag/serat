import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';

class AdhkarService {
  final AdhkarProgressService _progressService = AdhkarProgressService();
  List<AdhkarCategory>? _cachedCategories;

  Future<List<AdhkarCategory>> getAdhkarCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      // Load JSON data from assets
      final jsonString = await rootBundle.loadString('assets/data/adhkar.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert to AdhkarCategory objects
      final categories = jsonData.map((json) {
        return AdhkarCategory.fromJson(json);
      }).toList();

      // Load progress for each category
      final categoriesWithProgress = await Future.wait(
        categories.map((category) async {
          final progress =
              await _progressService.calculateCategoryProgress(category.id);
          return category.copyWith(progress: progress);
        }),
      );

      _cachedCategories = categoriesWithProgress;
      return categoriesWithProgress;
    } catch (e) {
      throw Exception('Failed to load adhkar data: $e');
    }
  }

  Future<AdhkarCategory?> getCategoryById(int id) async {
    final categories = await getAdhkarCategories();
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<AdhkarCategory?> getCategoryByName(String name) async {
    final categories = await getAdhkarCategories();
    try {
      return categories.firstWhere((category) => category.category == name);
    } catch (e) {
      return null;
    }
  }

  Future<List<AdhkarCategory>> searchCategories(String query) async {
    final categories = await getAdhkarCategories();
    return categories.where((category) {
      return category.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<AdhkarCategory>> getCategoriesByProgress(
      double minProgress) async {
    final categories = await getAdhkarCategories();
    return categories.where((category) {
      return category.progress >= minProgress;
    }).toList();
  }

  Future<void> refreshCategories() async {
    _cachedCategories = null;
    await getAdhkarCategories();
  }

  Future<Map<String, dynamic>> getCategoryStats() async {
    final categories = await getAdhkarCategories();
    final totalCategories = categories.length;
    final completedCategories =
        categories.where((c) => c.progress >= 1.0).length;
    final inProgressCategories =
        categories.where((c) => c.progress > 0 && c.progress < 1.0).length;
    final notStartedCategories =
        categories.where((c) => c.progress == 0).length;

    return {
      'total': totalCategories,
      'completed': completedCategories,
      'inProgress': inProgressCategories,
      'notStarted': notStartedCategories,
      'overallProgress':
          totalCategories > 0 ? completedCategories / totalCategories : 0.0,
    };
  }

  Future<List<AdhkarCategory>> getRecommendedCategories() async {
    final categories = await getAdhkarCategories();

    // Sort by progress (lowest first) to recommend categories that need attention
    categories.sort((a, b) => a.progress.compareTo(b.progress));

    // Return first 5 categories
    return categories.take(5).toList();
  }

  Future<List<AdhkarCategory>> getRecentlyCompleted() async {
    final categories = await getAdhkarCategories();

    // Filter completed categories and sort by some criteria (could be by completion date if tracked)
    final completed = categories.where((c) => c.progress >= 1.0).toList();

    // For now, return all completed categories
    return completed;
  }
}
