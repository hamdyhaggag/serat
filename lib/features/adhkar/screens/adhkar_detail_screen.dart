import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart'
    show CustomAppBar;
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';
import 'package:serat/features/adhkar/widgets/view_mode_selector.dart';
import 'package:serat/Data/utils/cache_helper.dart';

class AdhkarDetailScreen extends StatefulWidget {
  final AdhkarCategory category;
  final int initialItemIndex;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
    this.initialItemIndex = 0,
  });

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final AdhkarProgressService _progressService = AdhkarProgressService();
  int _currentItemIndex = 0;
  Map<int, int> _itemProgress = {};
  double _categoryProgress = 0.0;
  AdhkarViewMode _viewMode = AdhkarViewMode.list;
  bool _hasProgressChanged = false;

  // Text size slider state
  double _textScale = 28.0;
  bool _showTextSizeSlider = false;

  // Cache key for text scale
  static const String _textScaleKey = 'adhkar_text_scale';

  @override
  void initState() {
    super.initState();
    _currentItemIndex = widget.initialItemIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _loadProgress();
    _loadViewMode();
    _loadTextScale();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadViewMode() async {
    final savedMode = await _progressService.getViewMode();
    setState(() {
      _viewMode = AdhkarViewMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => AdhkarViewMode.list,
      );
    });
  }

  Future<void> _loadProgress() async {
    // Load progress for all items in the category
    for (int i = 0; i < widget.category.array.length; i++) {
      final progress = await _progressService.getItemProgress(
        widget.category.id,
        widget.category.array[i].id,
      );
      _itemProgress[i] = progress;
    }

    // Calculate overall category progress based on actual item counts
    double totalProgress = 0.0;
    int totalItems = widget.category.array.length;

    for (int i = 0; i < totalItems; i++) {
      final item = widget.category.array[i];
      final progress = _itemProgress[i] ?? 0;
      if (item.count > 0) {
        totalProgress += progress / item.count;
      }
    }

    _categoryProgress = totalItems > 0 ? totalProgress / totalItems : 0.0;

    // Save category progress for the main screen
    await _progressService.saveProgress(
        widget.category.category, _categoryProgress);

    // Update last opened progress
    await _progressService.updateLastOpenedProgress(_categoryProgress);

    if (mounted) {
      setState(() {});
      _progressController.forward();
    }
  }

  Future<bool> _updateItemProgress(int itemIndex) async {
    final item = widget.category.array[itemIndex];
    final currentProgress = _itemProgress[itemIndex] ?? 0;

    if (currentProgress < item.count) {
      final newProgress = currentProgress + 1;
      _itemProgress[itemIndex] = newProgress;
      _hasProgressChanged = true;

      await _progressService.saveItemProgress(
        widget.category.id,
        item.id,
        newProgress,
      );

      // Update category progress
      double totalProgress = 0.0;
      int totalItems = widget.category.array.length;

      for (int i = 0; i < totalItems; i++) {
        final item = widget.category.array[i];
        final progress = _itemProgress[i] ?? 0;
        if (item.count > 0) {
          totalProgress += progress / item.count;
        }
      }

      _categoryProgress = totalItems > 0 ? totalProgress / totalItems : 0.0;

      // Save category progress for the main screen
      await _progressService.saveProgress(
          widget.category.category, _categoryProgress);

      // Update last opened progress
      await _progressService.updateLastOpenedProgress(_categoryProgress);

      if (mounted) {
        setState(() {});
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
      }

      return true;
    }

    return false;
  }

  Future<void> _updateViewMode(AdhkarViewMode mode) async {
    setState(() {
      _viewMode = mode;
    });
    await _progressService.saveViewMode(mode.name);
  }

  Future<void> _loadTextScale() async {
    final savedTextScale = CacheHelper.getDouble(key: _textScaleKey);
    if (savedTextScale > 0) {
      setState(() {
        _textScale = savedTextScale;
      });
    }
  }

  Future<void> _saveTextScale(double value) async {
    await CacheHelper.saveData(
      key: _textScaleKey,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.category.category,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              setState(() {
                _showTextSizeSlider = !_showTextSizeSlider;
              });
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Fixed dots section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Professional progress indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: _buildProfessionalProgressIndicator(),
                  ),

                  // Text size slider
                  if (_showTextSizeSlider)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _buildCustomTextSizeSlider(),
                    ),

                  // View mode selector
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ViewModeSelector(
                      currentMode: _viewMode,
                      onModeChanged: _updateViewMode,
                    ),
                  ),

                  // Page indicator (fixed)
                  _buildPageIndicator(),

                  // Subtle separator
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.dividerColor.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content
          SliverToBoxAdapter(
            child: _buildAdhkarContent(),
          ),

          // Navigation controls (if horizontal mode)
          if (_viewMode == AdhkarViewMode.horizontal)
            SliverToBoxAdapter(
              child: _buildNavigationControls(),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalProgressIndicator() {
    final theme = Theme.of(context);
    final completedItems = _itemProgress.values.where((p) => p > 0).length;
    final totalItems = widget.category.array.length;
    final isCompleted = _categoryProgress >= 1.0;

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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted ? Icons.celebration : Icons.auto_awesome,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedItems/$totalItems',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'أذكار مكتملة',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 12,
                width:
                    MediaQuery.of(context).size.width * 0.8 * _categoryProgress,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? Colors.green : theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted
                              ? Colors.green
                              : theme.colorScheme.onPrimary)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(_categoryProgress * 100).toInt()}% مكتمل',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final totalItems = widget.category.array.length;
    final currentIndex = _currentItemIndex;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Counter display
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${currentIndex + 1} من $totalItems',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),

        // Dots indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              if (currentIndex > 0)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentItemIndex = currentIndex - 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Dots with smart pagination
              ..._buildSmartDots(currentIndex, totalItems, theme),

              const SizedBox(width: 12),

              // Next button
              if (currentIndex < totalItems - 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentItemIndex = currentIndex + 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, int currentIndex, ThemeData theme) {
    final isActive = index == currentIndex;
    final progress = _itemProgress[index] ?? 0;
    final isCompleted = progress > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.primaryColor
            : isCompleted
                ? Colors.green.withOpacity(0.6)
                : theme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  List<Widget> _buildSmartDots(
      int currentIndex, int totalItems, ThemeData theme) {
    final List<Widget> dots = [];
    final int maxVisibleDots = 5;

    // Show all dots if 7 or fewer items
    if (totalItems <= 7) {
      for (int i = 0; i < totalItems; i++) {
        dots.add(_buildDot(i, currentIndex, theme));
      }
      return dots;
    }

    // Smart pagination logic for more than 7 items
    int startIndex = 0;
    int endIndex = totalItems - 1;

    if (currentIndex <= 2) {
      // Near the beginning
      endIndex = maxVisibleDots - 1;
    } else if (currentIndex >= totalItems - 3) {
      // Near the end
      startIndex = totalItems - maxVisibleDots;
    } else {
      // In the middle
      startIndex = currentIndex - 2;
      endIndex = currentIndex + 2;
    }

    // Add first dot if not showing from beginning
    if (startIndex > 0) {
      dots.add(_buildDot(0, currentIndex, theme));
      if (startIndex > 1) {
        dots.add(_buildEllipsis(theme));
      }
    }

    // Add visible dots
    for (int i = startIndex; i <= endIndex; i++) {
      dots.add(_buildDot(i, currentIndex, theme));
    }

    // Add last dot if not showing to end
    if (endIndex < totalItems - 1) {
      if (endIndex < totalItems - 2) {
        dots.add(_buildEllipsis(theme));
      }
      dots.add(_buildDot(totalItems - 1, currentIndex, theme));
    }

    return dots;
  }

  Widget _buildEllipsis(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: theme.primaryColor.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdhkarContent() {
    switch (_viewMode) {
      case AdhkarViewMode.list:
        return _buildListView();
      case AdhkarViewMode.horizontal:
        return _buildHorizontalView();
    }
  }

  Widget _buildListView() {
    return Column(
      children: List.generate(
        widget.category.array.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildAdhkarItemCard(index),
        ),
      ),
    );
  }

  Widget _buildHorizontalView() {
    // Calculate responsive height based on text scale - increased for better text display
    final baseHeight = 320.0; // Increased base height for better text display
    final heightMultiplier = (_textScale - 28) *
        3.0; // Increased multiplier for more responsive scaling
    final responsiveHeight =
        (baseHeight + heightMultiplier).clamp(320.0, 500.0); // Increased range

    return Container(
      height: responsiveHeight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: widget.category.array.length,
        itemBuilder: (context, index) {
          return Container(
            width: (280 + (_textScale - 28) * 4.0)
                .clamp(280.0, 450.0), // Slightly increased width
            margin: const EdgeInsets.only(right: 16),
            child: _buildHorizontalAdhkarCard(index),
          );
        },
      ),
    );
  }

  Widget _buildAdhkarItemCard(int index) {
    final item = widget.category.array[index];
    final currentProgress = _itemProgress[index] ?? 0;
    final isCompleted = currentProgress >= item.count;
    final isCurrentItem = index == _currentItemIndex;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentItemIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isCurrentItem ? 8.0 : 4.0,
          shadowColor: theme.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isCurrentItem
                ? BorderSide(color: theme.primaryColor, width: 2)
                : BorderSide.none,
          ),
          color: isCurrentItem
              ? theme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          child: Padding(
            padding: EdgeInsets.all(16 + (_textScale - 28) * 0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.format_list_numbered,
                        size: 20,
                        color: isCompleted ? Colors.green : theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أذكار ${index + 1}',
                            style: TextStyle(
                              fontSize: _textScale * 0.7,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '$currentProgress/${item.count}',
                            style: TextStyle(
                              fontSize: _textScale * 0.8,
                              color: isCompleted
                                  ? Colors.green
                                  : theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: 12 + (_textScale - 28) * 0.4), // Dynamic spacing
                LinearProgressIndicator(
                  value: item.count > 0 ? currentProgress / item.count : 0.0,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : theme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: _textScale * 0.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                  maxLines: null, // Allow unlimited lines
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8),
                SizedBox(
                    height: 12 + (_textScale - 28) * 0.4), // Dynamic spacing
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isCompleted ? null : () => _updateItemProgress(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCompleted ? Colors.green : theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                          vertical:
                              8 + (_textScale - 28) * 0.4), // Dynamic padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: isCompleted ? 0 : 2,
                    ),
                    child: Text(
                      isCompleted ? 'مكتمل' : 'إكمال',
                      style: TextStyle(fontSize: _textScale * 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalAdhkarCard(int index) {
    final item = widget.category.array[index];
    final currentProgress = _itemProgress[index] ?? 0;
    final isCompleted = currentProgress >= item.count;
    final isCurrentItem = index == _currentItemIndex;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentItemIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isCurrentItem ? 8.0 : 4.0,
          shadowColor: theme.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isCurrentItem
                ? BorderSide(color: theme.primaryColor, width: 2)
                : BorderSide.none,
          ),
          color: isCurrentItem
              ? theme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          child: Padding(
            padding: EdgeInsets.all(
                14 + (_textScale - 28) * 0.4), // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compact header with icon and progress - reduced height
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          5 + (_textScale - 28) * 0.1), // Reduced padding
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.format_list_numbered,
                        size: 14 + (_textScale - 28) * 0.2, // Smaller icon
                        color: isCompleted ? Colors.green : theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أذكار ${index + 1}',
                            style: TextStyle(
                              fontSize:
                                  (_textScale - 28) * 0.25 + 11, // Smaller text
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '$currentProgress/${item.count}',
                            style: TextStyle(
                              fontSize:
                                  (_textScale - 28) * 0.15 + 9, // Smaller text
                              color: isCompleted
                                  ? Colors.green
                                  : theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                    height: 6 + (_textScale - 28) * 0.15), // Reduced spacing

                // Compact progress indicator - reduced height
                LinearProgressIndicator(
                  value: item.count > 0 ? currentProgress / item.count : 0.0,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : theme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  minHeight: 3 + (_textScale - 28) * 0.08, // Reduced height
                ),

                SizedBox(
                    height: 6 + (_textScale - 28) * 0.15), // Reduced spacing

                // Expanded adhkar text - now takes most of the space
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize:
                            (_textScale - 28) * 0.5 + 16, // Increased text size
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.9), // Better contrast
                        height: 1.5, // Better line height
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.justify, // Better text alignment
                    ),
                  ),
                ),

                SizedBox(
                    height: 6 + (_textScale - 28) * 0.15), // Reduced spacing

                // Compact action button - reduced height
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isCompleted ? null : () => _updateItemProgress(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCompleted ? Colors.green : theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                          vertical:
                              5 + (_textScale - 28) * 0.15), // Reduced padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: isCompleted ? 0 : 1, // Reduced elevation
                    ),
                    child: Text(
                      isCompleted ? 'مكتمل' : 'إكمال',
                      style: TextStyle(
                        fontSize: (_textScale - 28) * 0.15 + 9, // Smaller text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16, vertical: 8 + (_textScale - 28) * 0.2),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentItemIndex > 0
                  ? () {
                      setState(() {
                        _currentItemIndex--;
                      });
                    }
                  : null,
              icon: Icon(
                Icons.chevron_left,
                size: 16 + (_textScale - 28) * 0.2,
              ),
              label: Text(
                'السابق',
                style: TextStyle(
                  fontSize: (_textScale - 28) * 0.2 + 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: 8 + (_textScale - 28) * 0.2,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Next button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentItemIndex < widget.category.array.length - 1
                  ? () {
                      setState(() {
                        _currentItemIndex++;
                      });
                    }
                  : null,
              icon: Icon(
                Icons.chevron_right,
                size: 16 + (_textScale - 28) * 0.2,
              ),
              label: Text(
                'التالي',
                style: TextStyle(
                  fontSize: (_textScale - 28) * 0.2 + 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: 8 + (_textScale - 28) * 0.2,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextSizeSlider() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2F2F2F) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.text_fields,
            size: 20,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor:
                    isDarkMode ? Colors.grey[700] : Colors.grey[300],
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Slider(
                value: _textScale,
                min: 28.0,
                max: 48.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _textScale = value;
                  });
                  _saveTextScale(value);
                },
              ),
            ),
          ),
          Icon(
            Icons.text_fields,
            size: 24,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _showTextSizeSlider = false;
              });
            },
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
