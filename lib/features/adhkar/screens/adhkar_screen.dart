import 'package:flutter/material.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';
import 'package:serat/features/adhkar/services/adhkar_service.dart';
import 'package:serat/features/adhkar/widgets/adhkar_category_card.dart';
import 'package:serat/features/adhkar/widgets/adhkar_search_widget.dart';
import 'package:serat/features/adhkar/screens/adhkar_detail_screen.dart';
import 'package:serat/shared/constants/app_colors.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with TickerProviderStateMixin {
  final AdhkarService _adhkarService = AdhkarService();
  final AdhkarProgressService _progressService = AdhkarProgressService();

  late Future<List<AdhkarCategory>> _categories;
  Map<String, double> _categoryProgress = {};
  String? _selectedCategory;
  bool _isLoading = true;
  bool _showSearch = false;
  List<AdhkarCategory> _displayedCategories = [];
  String? _lastOpenedCategory;
  double _lastOpenedProgress = 0.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _categories = _adhkarService.getAdhkarCategories();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAllProgress();
    _loadLastOpenedCategory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProgress() async {
    final progress = await _progressService.getAllProgress();
    if (mounted) {
      setState(() {
        _categoryProgress = progress;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _loadLastOpenedCategory() async {
    final prefs = await _progressService.getLastOpenedCategory();
    if (mounted) {
      setState(() {
        if (prefs != null) {
          _lastOpenedCategory = prefs['category'];
          _lastOpenedProgress = prefs['progress'] ?? 0.0;
        } else {
          _lastOpenedCategory = null;
          _lastOpenedProgress = 0.0;
        }
      });
    }
  }

  Future<void> _updateLastOpenedCategoryProgress() async {
    if (_lastOpenedCategory != null) {
      final currentProgress = _categoryProgress[_lastOpenedCategory!] ?? 0.0;
      await _progressService.saveLastOpenedCategory(
          _lastOpenedCategory!, currentProgress);
      setState(() {
        _lastOpenedProgress = currentProgress;
      });
    }
  }

  Future<void> _updateSpecificCategoryProgress(String categoryName) async {
    try {
      // Get the specific category
      final category = await _adhkarService.getCategoryByName(categoryName);
      if (category == null || !mounted) return;

      // Calculate progress for this specific category
      double totalProgress = 0.0;
      int totalItems = category.array.length;

      for (final item in category.array) {
        if (!mounted) return;
        final progress =
            await _progressService.getItemProgress(category.id, item.id);
        if (item.count > 0) {
          totalProgress += progress / item.count;
        }
      }

      final categoryProgress =
          totalItems > 0 ? totalProgress / totalItems : 0.0;

      // Update the progress map
      if (mounted) {
        setState(() {
          _categoryProgress[categoryName] = categoryProgress;
        });
      }

      // Save the progress
      await _progressService.saveProgress(categoryName, categoryProgress);
    } catch (e) {
      // Fallback to loading all progress
      if (mounted) {
        await _loadAllProgress();
      }
    }
  }

  Future<void> _recalculateAndSaveAllProgress() async {
    try {
      // Get all categories and recalculate their progress
      final categories = await _adhkarService.getAdhkarCategories();
      Map<String, double> newProgress = {};

      // Process categories in batches to avoid blocking UI
      for (final category in categories) {
        if (!mounted) return; // Check if widget is still mounted

        double totalProgress = 0.0;
        int totalItems = category.array.length;

        for (final item in category.array) {
          if (!mounted) return; // Check if widget is still mounted
          final progress =
              await _progressService.getItemProgress(category.id, item.id);
          if (item.count > 0) {
            totalProgress += progress / item.count;
          }
        }

        final categoryProgress =
            totalItems > 0 ? totalProgress / totalItems : 0.0;
        newProgress[category.category] = categoryProgress;

        // Save the calculated progress
        await _progressService.saveProgress(
            category.category, categoryProgress);
      }

      if (mounted) {
        setState(() {
          _categoryProgress = newProgress;
        });
      }
    } catch (e) {
      // If there's an error, fall back to loading existing progress
      if (mounted) {
        await _loadAllProgress();
      }
    }
  }

  void _onSearchResults(List<AdhkarCategory> results) {
    setState(() {
      _displayedCategories = results;
    });
  }

  Future<void> _onCategoryTap(AdhkarCategory category) async {
    setState(() {
      _selectedCategory = category.category;
    });

    // Save as last opened category with current progress
    final currentProgress = _categoryProgress[category.category] ?? 0.0;
    await _progressService.saveLastOpenedCategory(
        category.category, currentProgress);

    // Navigate to detail screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdhkarDetailScreen(category: category),
      ),
    );

    // Always update progress and last opened category after returning
    if (mounted) {
      await _updateSpecificCategoryProgress(category.category);
      await _updateLastOpenedCategoryProgress();
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  IconData _getIconForCategory(String categoryName) {
    if (categoryName.contains('الصباح')) {
      return Icons.wb_sunny_rounded;
    } else if (categoryName.contains('المساء')) {
      return Icons.nightlight_round;
    } else if (categoryName.contains('النوم')) {
      return Icons.bedtime_rounded;
    } else if (categoryName.contains('الاستيقاظ')) {
      return Icons.alarm_rounded;
    } else if (categoryName.contains('الطعام')) {
      return Icons.restaurant_rounded;
    } else if (categoryName.contains('الخروج')) {
      return Icons.exit_to_app_rounded;
    } else if (categoryName.contains('الدخول')) {
      return Icons.login_rounded;
    } else if (categoryName.contains('المسجد')) {
      return Icons.mosque_rounded;
    } else if (categoryName.contains('السفر')) {
      return Icons.flight_rounded;
    } else if (categoryName.contains('الاستغفار')) {
      return Icons.person_rounded;
    } else if (categoryName.contains('التسبيح')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.apps_outage_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          'الأذكار',
          style: TextStyle(
            fontSize: 23,
            fontFamily: 'DIN',
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _displayedCategories = [];
                }
              });
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<AdhkarCategory>>(
          future: _categories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('لا توجد بيانات متاحة'),
              );
            } else {
              final categories = snapshot.data!;
              if (_displayedCategories.isEmpty && !_showSearch) {
                _displayedCategories = categories;
              }
              return _buildContent(categories);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<AdhkarCategory> categories) {
    return Column(
      children: [
        // Search widget
        if (_showSearch) ...[
          AdhkarSearchWidget(
            allCategories: categories,
            onSearchResults: _onSearchResults,
          ),
        ],

        // Header with last opened category progress
        Container(
          padding: const EdgeInsets.all(16),
          child: _buildLastOpenedProgressHeader(),
        ),

        // Categories content
        Expanded(
          child: _buildCategoriesView(_displayedCategories),
        ),
      ],
    );
  }

  Widget _buildLastOpenedProgressHeader() {
    final theme = Theme.of(context);

    if (_lastOpenedCategory == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text column on the left
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً بك',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ابدأ رحلتك مع الأذكار',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Icon on the right
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text column on the left
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آخر فئة مفتوحة',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(_lastOpenedProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Icon on the right
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _lastOpenedProgress >= 1.0
                      ? Icons.celebration
                      : Icons.auto_awesome,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _lastOpenedCategory!,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _lastOpenedProgress,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _lastOpenedProgress >= 1.0
                  ? Colors.green
                  : theme.colorScheme.onPrimary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesView(List<AdhkarCategory> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return _buildGridView(categories);
  }

  Widget _buildGridView(List<AdhkarCategory> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category.category;
        final progress = _categoryProgress[category.category] ?? 0.0;

        return AdhkarCategoryCard(
          category: category,
          icon: _getIconForCategory(category.category),
          onTap: () => _onCategoryTap(category),
          isSelected: isSelected,
          progress: progress,
        );
      },
    );
  }
}
