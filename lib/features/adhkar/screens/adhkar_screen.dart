import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';
import 'package:serat/features/adhkar/services/adhkar_service.dart';
import 'package:serat/features/adhkar/widgets/adhkar_category_card.dart';
import 'package:serat/features/adhkar/widgets/adhkar_search_widget.dart';
import 'package:serat/features/adhkar/screens/adhkar_detail_screen.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'package:serat/features/spiritual_progress/cubit/spiritual_cubit.dart';

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
  bool _showSearch = false;
  List<AdhkarCategory> _displayedCategories = [];
  String? _lastOpenedCategory;
  double _lastOpenedProgress = 0.0;

  late AnimationController _animationController;
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _categories = _adhkarService.getAdhkarCategories();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadAllProgress();
    _loadLastOpenedCategory();
    _sessionStopwatch.start();
    // Report every full minute to SpiritualCubit
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        SpiritualCubit.get(context).updateStats(
          adhkarCount: 1,
          totalWorshipMinutes: 1,
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _sessionStopwatch.stop();
    // Flush remaining partial minutes (>= 30 seconds counts as 1 minute)
    final remainingSecs = _sessionStopwatch.elapsed.inSeconds % 60;
    if (remainingSecs >= 30 && mounted) {
      SpiritualCubit.get(context).updateStats(
        adhkarCount: 1,
        totalWorshipMinutes: 1,
      );
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProgress() async {
    final progress = await _progressService.getAllProgress();
    if (mounted) {
      setState(() {
        _categoryProgress = progress;
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
      final category = await _adhkarService.getCategoryByName(categoryName);
      if (category == null || !mounted) return;

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

      if (mounted) {
        setState(() {
          _categoryProgress[categoryName] = categoryProgress;
        });
      }
      await _progressService.saveProgress(categoryName, categoryProgress);
    } catch (e) {
      if (mounted) await _loadAllProgress();
    }
  }

  void _onSearchResults(List<AdhkarCategory> results) {
    setState(() {
      _displayedCategories = results;
    });
  }

  Future<void> _onCategoryTap(AdhkarCategory category) async {
    final currentProgress = _categoryProgress[category.category] ?? 0.0;
    await _progressService.saveLastOpenedCategory(
        category.category, currentProgress);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdhkarDetailScreen(category: category),
      ),
    );

    if (mounted) {
      await _updateSpecificCategoryProgress(category.category);
      await _updateLastOpenedCategoryProgress();
    }
  }

  IconData _getIconForCategory(String categoryName) {
    if (categoryName.contains('الصباح')) return Icons.wb_sunny_rounded;
    if (categoryName.contains('المساء')) return Icons.nightlight_round;
    if (categoryName.contains('النوم')) return Icons.bedtime_rounded;
    if (categoryName.contains('الاستيقاظ')) return Icons.alarm_rounded;
    if (categoryName.contains('الطعام')) return Icons.restaurant_rounded;
    if (categoryName.contains('الخروج')) return Icons.exit_to_app_rounded;
    if (categoryName.contains('الدخول')) return Icons.login_rounded;
    if (categoryName.contains('المسجد')) return Icons.mosque_rounded;
    if (categoryName.contains('السفر')) return Icons.flight_rounded;
    if (categoryName.contains('الاستغفار')) return Icons.person_rounded;
    if (categoryName.contains('التسبيح')) return Icons.auto_awesome_rounded;
    return Icons.apps_outage_rounded;
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8F9FA),
      body: FutureBuilder<List<AdhkarCategory>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _buildErrorWidget(context, isDarkMode);
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return _buildEmptyWidget(context, isDarkMode);

          final categories = snapshot.data!;
          if (_displayedCategories.isEmpty && !_showSearch) {
            _displayedCategories = categories;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, isDarkMode),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showSearch)
                        AdhkarSearchWidget(
                          allCategories: categories,
                          onSearchResults: _onSearchResults,
                        ).animate().fade().slideY(begin: -0.1, end: 0),
                      const SizedBox(height: 16),
                      _buildPremiumHero(context),
                      const SizedBox(height: 32),
                      const Text(
                        "تصنيفات الأذكار",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fade(delay: 300.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridCrossAxisCount(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _displayedCategories[index];
                      final progress =
                          _categoryProgress[category.category] ?? 0.0;
                      return AdhkarCategoryCard(
                        category: category,
                        icon: _getIconForCategory(category.category),
                        onTap: () => _onCategoryTap(category),
                        progress: progress,
                      ).animate().fade(delay: (index * 50).ms).scale();
                    },
                    childCount: _displayedCategories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 140,
      automaticallyImplyLeading: false,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          'الأذكار النبوية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.9),
                    isDarkMode
                        ? const Color(0xff121212)
                        : const Color(0xffF8F9FA),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // Decorative pattern
            Positioned(
              right: -30,
              top: -10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 180,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search,
                  color: Colors.white, size: 20),
              onPressed: () => setState(() => _showSearch = !_showSearch),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHero(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 160,
      child: Stack(
        children: [
          // Background Card with Glassmorphism feel
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [const Color(0xff2A2A2A), const Color(0xff1E1E1E)]
                      : [Colors.white, const Color(0xffF0F4F8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor
                        .withOpacity(isDarkMode ? 0.2 : 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.8),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Pattern Overlay
          Positioned(
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(32)),
              child: Opacity(
                opacity: 0.03,
                child: Icon(Icons.apps_rounded,
                    size: 120, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),

          // Content Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "وردك اليومي",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "حافظ على أذكارك",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xff1A1C1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "« ألا بذكر الله تطمئن القلوب »",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Action Circle
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                    begin: -5,
                    end: 5,
                    duration: 2.seconds,
                    curve: Curves.easeInOut),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }

  Widget _buildErrorWidget(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "حدث خطأ ما",
            style: TextStyle(fontFamily: "Cairo", fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "لا توجد أذكار حالياً",
            style: TextStyle(fontFamily: "Cairo", fontSize: 18),
          ),
        ],
      ),
    );
  }
}
