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
      body: Column(
        children: [
          // Professional progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildProfessionalProgressIndicator(),
          ),

          // Text size slider
          if (_showTextSizeSlider)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildCustomTextSizeSlider(),
            ),

          // View mode selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'طريقة العرض:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 12),
                ViewModeSelector(
                  currentMode: _viewMode,
                  onModeChanged: _updateViewMode,
                ),
              ],
            ),
          ),

          // Page indicator
          _buildPageIndicator(),

          // Adhkar content
          Expanded(
            child: _buildAdhkarContent(),
          ),

          // Navigation controls
          if (_viewMode == AdhkarViewMode.horizontal)
            _buildNavigationControls(),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.category.array.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: index == _currentItemIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == _currentItemIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.array.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAdhkarItemCard(index),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: widget.category.array.length,
        itemBuilder: (context, index) {
          return Container(
            width: (300 + (_textScale - 28) * 6).clamp(300.0, 500.0),
            margin: const EdgeInsets.only(right: 16),
            child: _buildAdhkarItemCard(index),
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
          child: Container(
            constraints: BoxConstraints(
              minHeight: 250,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                            color:
                                isCompleted ? Colors.green : theme.primaryColor,
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
                        height:
                            12 + (_textScale - 28) * 0.4), // Dynamic spacing
                    LinearProgressIndicator(
                      value:
                          item.count > 0 ? currentProgress / item.count : 0.0,
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
                        height:
                            12 + (_textScale - 28) * 0.4), // Dynamic spacing
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () => _updateItemProgress(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCompleted ? Colors.green : theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                              vertical: 8 +
                                  (_textScale - 28) * 0.4), // Dynamic padding
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
        ),
      ),
    );
  }

  Widget _buildAdhkarItem(int index) {
    final item = widget.category.array[index];
    final currentProgress = _itemProgress[index] ?? 0;
    final isCompleted = currentProgress >= item.count;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Item progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}/${widget.category.array.length}',
                      style: TextStyle(
                        fontSize: _textScale * 0.7,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$currentProgress/${item.count}',
                      style: TextStyle(
                        fontSize: _textScale * 0.8,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: item.count > 0 ? currentProgress / item.count : 0.0,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : theme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Adhkar text
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24 +
                  (_textScale - 28) *
                      1.0), // Dynamic padding based on text scale
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        item.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _textScale,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isCompleted ? null : () => _updateItemProgress(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCompleted ? Colors.green : theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isCompleted ? 0 : 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCompleted) ...[
                            const Icon(Icons.check_circle, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'مكتمل',
                              style: TextStyle(
                                fontSize: _textScale * 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.touch_app, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'اضغط لإكمال',
                              style: TextStyle(
                                fontSize: _textScale * 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentItemIndex > 0
                  ? () {
                      setState(() {
                        _currentItemIndex--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_ios),
              label: Text(
                'السابق',
                style: TextStyle(fontSize: _textScale * 0.7),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _currentItemIndex < widget.category.array.length - 1
                  ? () {
                      setState(() {
                        _currentItemIndex++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios),
              label: Text(
                'التالي',
                style: TextStyle(fontSize: _textScale * 0.7),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
