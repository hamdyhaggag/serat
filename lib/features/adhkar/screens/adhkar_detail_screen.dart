import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart'
    show CustomAppBar;
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/features/adhkar/services/adhkar_progress_service.dart';
import 'package:serat/features/adhkar/widgets/adhkar_shimmer.dart';
import 'package:serat/features/adhkar/widgets/view_mode_selector.dart';
import 'package:serat/Data/utils/cache_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/features/adhkar/widgets/adhkar_item_card.dart';

// Widget for sharing: includes card, logo, and text at the bottom
class AdhkarShareCard extends StatelessWidget {
  final Widget cardContent;
  const AdhkarShareCard({Key? key, required this.cardContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF23272F) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final logoAsset = isDark
        ? 'assets/logo.png'
        : 'assets/logo.png'; // Change to 'assets/logo_dark.png' if you have a dark logo

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cardContent,
          const SizedBox(height: 24),
          Divider(thickness: 1, color: dividerColor),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logoAsset,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                ' تمت المشاركة من تطبيق صِراط',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper to capture a widget to image
Future<RenderRepaintBoundary> _captureWidgetToImage(
    Widget widget, GlobalKey key, Size logicalSize) async {
  final repaintBoundary = RenderRepaintBoundary();
  final view = WidgetsBinding.instance.platformDispatcher.implicitView ??
      WidgetsBinding.instance.platformDispatcher.views.first;
  final renderView = RenderView(
    child: repaintBoundary,
    configuration: ViewConfiguration(
      devicePixelRatio: 3.0,
    ),
    view: view,
  );
  final pipelineOwner = PipelineOwner();
  pipelineOwner.rootNode = renderView;
  final buildOwner = BuildOwner(focusManager: FocusManager());
  final renderElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: widget,
  ).attachToRenderTree(buildOwner);
  buildOwner.buildScope(renderElement);
  buildOwner.finalizeTree();
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  return repaintBoundary;
}

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
  final Map<int, GlobalKey> _cardKeys = {};
  final GlobalKey _shareBoundaryKey = GlobalKey();
  int? _shareCardIndex; // null means not sharing
  int _currentItemIndex = 0;
  Map<int, int> _itemProgress = {};
  double _categoryProgress = 0.0;
  AdhkarViewMode _viewMode = AdhkarViewMode.list;
  bool _hasProgressChanged = false;
  bool _isLoading = true;
  bool _isResetting = false;

  // Text size slider state
  double _textScale = 28.0;
  bool _showTextSizeSlider = false;

  // Cache key for text scale
  static const String _textScaleKey = 'adhkar_text_scale';

  // --- Added for auto-scroll ---
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  // --- End added ---

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

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadProgress();
    await _loadViewMode();
    await _loadTextScale();

    // Check if we should show the continuation dialog
    if (mounted) {
      await _checkAndShowContinuationDialog();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _verticalScrollController.dispose(); // Dispose controllers
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowContinuationDialog() async {
    final hasProgress =
        await _progressService.hasCategoryProgress(widget.category.id);

    if (hasProgress) {
      final shouldShow =
          await _progressService.shouldShowResetDialog(widget.category.id);

      if (shouldShow && mounted) {
        await _showContinuationDialog();
      }
    }
  }

  Future<void> _showContinuationDialog() async {
    final lastCompleted =
        await _progressService.getLastCompletedAdhkar(widget.category.id);
    final sessionData =
        await _progressService.getSessionData(widget.category.id);

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _buildContinuationDialog(lastCompleted, sessionData),
    );

    if (result != null && mounted) {
      if (result) {
        // Continue from where left off
        await _continueFromLastPosition(sessionData);
      } else {
        // Start fresh
        await _resetAndStartFresh();
      }

      // Mark dialog as shown
      await _progressService.markResetDialogShown(widget.category.id);
    }
  }

  Widget _buildContinuationDialog(
      Map<String, dynamic>? lastCompleted, Map<String, dynamic>? sessionData) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    String dialogTitle = 'مرحباً بك مرة أخرى!';
    String dialogMessage = 'هل تريد الاستمرار من حيث توقفت أم البدء من جديد؟';

    if (lastCompleted != null) {
      final itemText = lastCompleted['itemText'] as String? ?? '';
      final shortText =
          itemText.length > 50 ? '${itemText.substring(0, 50)}...' : itemText;
      dialogMessage =
          'آخر ذكر قمت به:\n"$shortText"\n\nهل تريد الاستمرار من حيث توقفت أم البدء من جديد؟';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              dialogTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Message
            Text(
              dialogMessage,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Continue button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('استمر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Reset button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('ابدأ من جديد'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continueFromLastPosition(
      Map<String, dynamic>? sessionData) async {
    if (sessionData != null) {
      final savedIndex = sessionData['currentItemIndex'] as int? ?? 0;
      setState(() {
        _currentItemIndex = savedIndex;
      });
    } else {
      // Find next incomplete item
      final nextIndex = await _progressService.getNextIncompleteItemIndex(
        widget.category.id,
        widget.category.array,
      );
      setState(() {
        _currentItemIndex = nextIndex;
      });
    }
  }

  Future<void> _resetAndStartFresh() async {
    setState(() {
      _isResetting = true;
    });

    await _progressService.resetCategoryProgress(
      widget.category.id,
      widget.category.category,
    );

    // Simulate a small delay for the shimmer effect to be visible
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentItemIndex = 0;
      _itemProgress.clear();
      _categoryProgress = 0.0;
      _isResetting = false;
    });

    await _loadProgress();
  }

  Future<void> _showResetConfirmationDialog() async {
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('إعادة تعيين التقدم'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد إعادة تعيين جميع التقدم المحفوظ؟\n\nلا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _resetAndStartFresh();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إعادة تعيين التقدم بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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

    // Save session data
    await _progressService.saveSessionData(
      widget.category.id,
      _currentItemIndex,
      _categoryProgress,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _updateItemProgress(int itemIndex) async {
    final item = widget.category.array[itemIndex];
    final currentProgress = _itemProgress[itemIndex] ?? 0;

    if (currentProgress < item.count) {
      final newProgress = currentProgress + 1;
      // Optimistically update UI state first
      setState(() {
        _itemProgress[itemIndex] = newProgress;
        _hasProgressChanged = true;
        // Optionally update _categoryProgress for instant feedback
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
      });
      _animationController
          .forward()
          .then((_) => _animationController.reverse());

      // --- Auto-scroll logic after completion ---
      if (newProgress >= item.count) {
        final nextIndex = itemIndex + 1;
        if (nextIndex < widget.category.array.length) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            if (_viewMode == AdhkarViewMode.horizontal) {
              // Horizontal scroll
              _scrollToHorizontalIndex(nextIndex);
            } else if (_viewMode == AdhkarViewMode.list) {
              // Vertical scroll
              _scrollToVerticalIndex(nextIndex);
            }
          });
        }
      }
      // --- End auto-scroll logic ---

      // Perform async operations in the background
      () async {
        await _progressService.saveItemProgress(
          widget.category.id,
          item.id,
          newProgress,
        );

        // Save last completed adhkar
        if (newProgress >= item.count) {
          await _progressService.saveLastCompletedAdhkar(
            widget.category.id,
            itemIndex,
            item.id,
            item.text,
          );
        }

        // Save category progress for the main screen
        await _progressService.saveProgress(
            widget.category.category, _categoryProgress);

        // Update last opened progress
        await _progressService.updateLastOpenedProgress(_categoryProgress);

        // Save session data
        await _progressService.saveSessionData(
          widget.category.id,
          _currentItemIndex,
          _categoryProgress,
        );
      }();

      return true;
    }

    return false;
  }

  // --- Helper methods for auto-scroll ---
  void _scrollToVerticalIndex(int index) {
    final key = _cardKeys[index];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    } else {
      // Fallback: scroll by offset
      _verticalScrollController.animateTo(
        (index * 120.0)
            .clamp(0, _verticalScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToHorizontalIndex(int index) {
    final key = _cardKeys[index];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    } else {
      // Fallback: scroll by offset
      _horizontalScrollController.animateTo(
        (index * 300.0)
            .clamp(0, _horizontalScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
  // --- End helper methods ---

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

  Future<void> _shareAdhkarCardWithLogo(int index) async {
    // Preload the logo asset before capturing
    await precacheImage(const AssetImage('assets/logo.png'), context);
    // Wait for the next frame to ensure the image is painted
    await Future.delayed(const Duration(milliseconds: 50));
    await WidgetsBinding.instance.endOfFrame;
    try {
      RenderRepaintBoundary boundary = _shareBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/adhkar.png').create();
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Serat Adhkar',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing Adhkar: $e')),
      );
    } finally {
      setState(() {
        _shareCardIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Offstage share widget (for screenshot)
    Widget? offstageShareWidget;
    if (_shareCardIndex != null) {
      final item = widget.category.array[_shareCardIndex!];
      final currentProgress = _itemProgress[_shareCardIndex!] ?? 0;
      final isCompleted = currentProgress >= item.count;
      final isCurrentItem = _shareCardIndex == _currentItemIndex;
      offstageShareWidget = Offstage(
        offstage: false,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: RepaintBoundary(
              key: _shareBoundaryKey,
              child: Theme(
                data: Theme.of(context),
                child: AdhkarShareCard(
                  cardContent: _buildAdhkarItemCardContent(
                    _shareCardIndex!,
                    isCurrentItem,
                    isCompleted,
                    currentProgress,
                    item,
                    theme,
                    forShare: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: widget.category.category),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: widget.category.category,
            actions: [
              // Reset button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _showResetConfirmationDialog,
                tooltip: 'إعادة تعيين التقدم',
              ),
              // Text size button
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: () {
                  setState(() {
                    _showTextSizeSlider = !_showTextSizeSlider;
                  });
                },
                tooltip: 'حجم النص',
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
                      // Text size slider
                      if (_showTextSizeSlider)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: _buildCustomTextSizeSlider(),
                        ),

                      // View mode selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
          bottomNavigationBar: _buildPersistentProgressBar(context),
        ),
        if (offstageShareWidget != null) offstageShareWidget,
      ],
    );
  }

  Widget _buildPersistentProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = _categoryProgress >= 1.0;
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress bar with gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _categoryProgress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 16,
                    backgroundColor: theme.primaryColor.withOpacity(0.10),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : theme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            // Percentage and icon overlay
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              '${(_categoryProgress * 100).toInt()}%',
                              key: ValueKey(
                                  _categoryProgress.toStringAsFixed(2)),
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.green[800]
                                    : theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: theme.primaryColor.withOpacity(0.08),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: isCompleted
                                ? Icon(Icons.celebration,
                                    color: Colors.green,
                                    size: 22,
                                    key: const ValueKey('done'))
                                : Icon(Icons.auto_awesome,
                                    color: theme.primaryColor,
                                    size: 20,
                                    key: const ValueKey('progress')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),

        // Dots indicator (no next/back buttons)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._buildSmartDots(currentIndex, totalItems, theme),
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdhkarContent() {
    if (_isResetting) {
      return const AdhkarShimmer();
    }

    switch (_viewMode) {
      case AdhkarViewMode.list:
        return _buildListView();
      case AdhkarViewMode.horizontal:
        return _buildHorizontalView();
      case AdhkarViewMode.grid:
        return _buildGridView();
    }
  }

  Widget _buildListView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: ListView(
        controller: _verticalScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: List.generate(
          widget.category.array.length,
          (index) {
            final cardKey = _cardKeys.putIfAbsent(index, () => GlobalKey());
            final item = widget.category.array[index];
            final currentProgress = _itemProgress[index] ?? 0;
            final isCompleted = currentProgress >= item.count;
            final isCurrentItem = index == _currentItemIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: RepaintBoundary(
                key: cardKey,
                child: AdhkarItemCard(
                  index: index,
                  item: item,
                  currentProgress: currentProgress,
                  isCompleted: isCompleted,
                  isCurrentItem: isCurrentItem,
                  textScale: _textScale,
                  isHorizontal: false,
                  forShare: false,
                  onTap: () {
                    setState(() {
                      _currentItemIndex = index;
                    });
                  },
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: item.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الذكر إلى الحافظة')),
                    );
                  },
                  onShare: () async {
                    setState(() {
                      _shareCardIndex = index;
                    });
                    await _shareAdhkarCardWithLogo(index);
                  },
                  onComplete:
                      isCompleted ? null : () => _updateItemProgress(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalView() {
    final baseHeight = 400.0; // Keep increased height
    final heightMultiplier = (_textScale - 28) * 4.0;
    final responsiveHeight =
        (baseHeight + heightMultiplier).clamp(400.0, 600.0);
    return SizedBox(
      height: responsiveHeight,
      child: Center(
        child: ListView.builder(
          controller: _horizontalScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          scrollDirection: Axis.horizontal,
          itemCount: widget.category.array.length,
          itemBuilder: (context, index) {
            final cardKey = _cardKeys.putIfAbsent(index, () => GlobalKey());
            final item = widget.category.array[index];
            final currentProgress = _itemProgress[index] ?? 0;
            final isCompleted = currentProgress >= item.count;
            final isCurrentItem = index == _currentItemIndex;
            return Align(
              alignment: Alignment.center,
              child: Container(
                width: (260 + (_textScale - 28) * 4.0)
                    .clamp(220.0, 340.0), // Decreased width
                margin: const EdgeInsets.symmetric(
                    horizontal: 16), // Slightly reduced margin
                child: RepaintBoundary(
                  key: cardKey,
                  child: AdhkarItemCard(
                    index: index,
                    item: item,
                    currentProgress: currentProgress,
                    isCompleted: isCompleted,
                    isCurrentItem: isCurrentItem,
                    textScale: _textScale,
                    isHorizontal: true,
                    forShare: false,
                    onTap: () {
                      setState(() {
                        _currentItemIndex = index;
                      });
                    },
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: item.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم نسخ الذكر إلى الحافظة')),
                      );
                    },
                    onShare: () async {
                      setState(() {
                        _shareCardIndex = index;
                      });
                      await _shareAdhkarCardWithLogo(index);
                    },
                    onComplete:
                        isCompleted ? null : () => _updateItemProgress(index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.category.array.length,
      itemBuilder: (context, index) {
        final cardKey = _cardKeys.putIfAbsent(index, () => GlobalKey());
        final item = widget.category.array[index];
        final currentProgress = _itemProgress[index] ?? 0;
        final isCompleted = currentProgress >= item.count;
        final isCurrentItem = index == _currentItemIndex;

        return RepaintBoundary(
          key: cardKey,
          child: AdhkarItemCard(
            index: index,
            item: item,
            currentProgress: currentProgress,
            isCompleted: isCompleted,
            isCurrentItem: isCurrentItem,
            textScale: _textScale,
            isHorizontal: false,
            forShare: false,
            onTap: () {
              setState(() {
                _currentItemIndex = index;
              });
            },
            onCopy: () {
              Clipboard.setData(ClipboardData(text: item.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الذكر إلى الحافظة')),
              );
            },
            onShare: () async {
              setState(() {
                _shareCardIndex = index;
              });
              await _shareAdhkarCardWithLogo(index);
            },
            onComplete: isCompleted ? null : () => _updateItemProgress(index),
          ),
        );
      },
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

  Widget _buildAdhkarItemCardContent(
    int index,
    bool isCurrentItem,
    bool isCompleted,
    int currentProgress,
    AdhkarItem item,
    ThemeData theme, {
    bool forShare = false,
  }) {
    return AdhkarItemCard(
      index: index,
      item: item,
      currentProgress: currentProgress,
      isCompleted: isCompleted,
      isCurrentItem: isCurrentItem,
      textScale: _textScale,
      isHorizontal: false,
      forShare: true,
    );
  }
}
