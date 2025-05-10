import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/models/daily_goal.dart';

class DailyGoalService {
  static const String _goalsKey = 'daily_goals';
  List<DailyGoal>? _cachedGoals;
  bool _isLoading = false;

  Future<List<DailyGoal>> getGoals() async {
    if (_cachedGoals != null) {
      return _cachedGoals!;
    }

    if (_isLoading) {
      return [];
    }

    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_goalsKey);

      if (goalsJson == null) {
        _cachedGoals = [];
        return [];
      }

      final List<dynamic> goalsList = json.decode(goalsJson);
      _cachedGoals = goalsList.map((item) => DailyGoal.fromJson(item)).toList();
      return _cachedGoals!;
    } catch (e) {
      print('Error loading daily goals: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  Future<void> saveGoals(List<DailyGoal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = json.encode(
        goals.map((goal) => goal.toJson()).toList(),
      );
      final success = await prefs.setString(_goalsKey, goalsJson);
      if (!success) {
        throw Exception('Failed to save goals to storage');
      }
      _cachedGoals = goals;
    } catch (e) {
      print('Error saving daily goals: $e');
      throw Exception('Failed to save goals: ${e.toString()}');
    }
  }

  Future<void> addGoal(DailyGoal goal) async {
    try {
      if (_cachedGoals == null) {
        await getGoals();
      }

      // Check if goal with same ID already exists
      if (_cachedGoals!.any((g) => g.id == goal.id)) {
        throw Exception('Goal already exists');
      }

      _cachedGoals!.insert(0, goal);
      await saveGoals(_cachedGoals!);
    } catch (e) {
      _cachedGoals = null; // Clear cache on error
      throw Exception('Failed to add goal: ${e.toString()}');
    }
  }

  Future<void> updateGoal(DailyGoal goal) async {
    try {
      final goals = await getGoals();
      final index = goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        goals[index] = goal;
        await saveGoals(goals);
      } else {
        throw Exception('Goal not found');
      }
    } catch (e) {
      print('Error updating daily goal: $e');
      throw Exception('Failed to update goal: ${e.toString()}');
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      final goals = await getGoals();
      final initialLength = goals.length;
      goals.removeWhere((goal) => goal.id == id);
      if (goals.length == initialLength) {
        throw Exception('Goal not found');
      }
      await saveGoals(goals);
    } catch (e) {
      print('Error deleting daily goal: $e');
      throw Exception('Failed to delete goal: ${e.toString()}');
    }
  }

  void clearCache() {
    _cachedGoals = null;
  }
}
