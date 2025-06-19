import 'package:flutter/material.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';
import 'package:serat/features/adhkar/services/adhkar_service.dart';
import 'package:serat/features/adhkar/widgets/adhkar_category_card.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final AdhkarService _adhkarService = AdhkarService();
  final AdhkarProgressService _progressService = AdhkarProgressService();
  late Future<List<AdhkarCategory>> _categories;
  double _progress = 0.0;
  final String _progressCategory = 'أذكار المساء';

  @override
  void initState() {
    super.initState();
    _categories = _adhkarService.getAdhkarCategories();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressService.getProgress(_progressCategory);
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  Future<void> _updateProgress(String category) async {
    if (category == _progressCategory) {
      double currentProgress = await _progressService.getProgress(category);
      currentProgress += 0.1;
      if (currentProgress > 1.0) {
        currentProgress = 1.0;
      }
      await _progressService.saveProgress(category, currentProgress);
      _loadProgress();
    }
    // TODO: Handle navigation or other actions for other cards
  }

  Future<void> _resetProgress() async {
    await _progressService.resetProgress(_progressCategory);
    _loadProgress();
  }

  IconData _getIconForCategory(String categoryName) {
    if (categoryName.contains('النوم')) {
      return Icons.nightlight_round;
    }
    // Placeholder icon for other categories
    return Icons.apps_outage_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأذكار',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AdhkarCategory>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final categories = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressCard(context),
                    const SizedBox(height: 24),
                    _buildCategoriesGrid(categories),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.apps_outage_rounded,
                    color: Theme.of(context).colorScheme.onPrimary, size: 28),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _progressCategory,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نسبة الإكمال',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: _resetProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'مسح التقدم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<AdhkarCategory> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return AdhkarCategoryCard(
          category: category,
          icon: _getIconForCategory(category.category),
          onTap: () => _updateProgress(category.category),
        );
      },
    );
  }
}
