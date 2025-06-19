import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_reset_button.dart' show AppButton;
import 'package:serat/Presentation/screens/azkar_screens/SebhaCounterSection.dart' show SebhaCounterSection;
import 'package:serat/imports.dart';
import 'package:serat/Business_Logic/Cubit/counter_cubit.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class Sebha extends StatefulWidget {
  final String title;
  final String subtitle;
  final int beadCount;
  final int? maxCounter;

  const Sebha({
    super.key,
    required this.title,
    required this.subtitle,
    required this.beadCount,
    this.maxCounter,
  });

  @override
  SebhaState createState() => SebhaState();
}

class SebhaState extends State<Sebha> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  AnimationController? _counterController;
  Animation<double>? _counterAnimation;
  bool _isLongPress = false;
  Timer? _longPressTimer;
  int _longPressCount = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initializeAnimations();
      await _loadCounters();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> _initializeAnimations() async {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _counterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _counterController!, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _counterController?.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCounters() async {
    if (!mounted) return;

    try {
      final counters = await loadSebhaCounter(widget.title);
      if (!mounted) return;

      final cubit = CounterCubit.get(context);
      cubit.initializeCounters(
        counter: counters['counter']!,
        totalCounter: counters['totalCounter']!,
        cycleCounter: counters['cycleCounter']!,
      );
      if (widget.maxCounter != null) {
        cubit.changeMaxCounter(widget.maxCounter!);
      }
    } catch (e) {
      debugPrint('Error loading counters: $e');
    }
  }

  void _handleCounterIncrement(CounterCubit cubit) async {
    if (!_isInitialized) return;

    HapticFeedback.mediumImpact();
    _counterController?.forward(from: 0.0);
    cubit.incrementCounter();
    await saveSebhaCounter(
      widget.title,
      cubit.counter,
      cubit.totalCounter,
      cubit.cycleCounter,
    );

    if (widget.maxCounter != null && cubit.counter >= widget.maxCounter!) {
      _showCompletionDialog();
    }
  }

  void _startLongPress(CounterCubit cubit) {
    if (!_isInitialized) return;

    _isLongPress = true;
    _longPressCount = 0;
    _longPressTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_isLongPress) {
        _longPressCount++;
        if (_longPressCount % 2 == 0) {
          _handleCounterIncrement(cubit);
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _stopLongPress() {
    _isLongPress = false;
    _longPressTimer?.cancel();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('أحسنت!'),
        content: const Text('لقد أكملت العدد المطلوب'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
        body: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            final cubit = CounterCubit.get(context);
            final progress = widget.maxCounter != null
                ? cubit.counter / widget.maxCounter!
                : 0.0;

            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView(
                children: [
                  SebhaCounterSection(
                    total: cubit.totalCounter,
                    currentCount: cubit.counter,
                    cycleCount: cubit.cycleCounter,
                    beadCount: widget.beadCount,
                    title: widget.title,
                    subtitle: widget.subtitle,
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTapDown: (_) {
                      _controller?.forward();
                      _startLongPress(cubit);
                    },
                    onTapUp: (_) {
                      _controller?.reverse();
                      _stopLongPress();
                      if (!_isLongPress) {
                        _handleCounterIncrement(cubit);
                      }
                    },
                    onTapCancel: () {
                      _controller?.reverse();
                      _stopLongPress();
                    },
                    child: ScaleTransition(
                      scale: _scaleAnimation!,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: size.width * 0.8,
                            height: size.width * 0.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDarkMode
                                    ? [
                                        const Color(0xFF2C2C2C),
                                        const Color(0xFF1A1A1A),
                                      ]
                                    : [
                                        AppColors.primaryColor.withOpacity(
                                          0.1,
                                        ),
                                        AppColors.primaryColor.withOpacity(
                                          0.05,
                                        ),
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black.withOpacity(0.3)
                                      : AppColors.primaryColor.withOpacity(
                                          0.1,
                                        ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey.withOpacity(0.2)
                                      : AppColors.primaryColor.withOpacity(
                                          0.2,
                                        ),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (widget.maxCounter != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.grey.withOpacity(0.2)
                                              : AppColors.primaryColor
                                                  .withOpacity(0.2),
                                          width: 3,
                                        ),
                                      ),
                                      child: CustomPaint(
                                        painter: ProgressPainter(
                                          progress: progress,
                                          color: isDarkMode
                                              ? Colors.grey
                                              : AppColors.primaryColor,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _counterAnimation!,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: 1.0 +
                                                  (_counterAnimation!.value *
                                                      0.1),
                                              child: Text(
                                                '${cubit.counter}',
                                                style: TextStyle(
                                                  fontSize: cubit.counter < 1000
                                                      ? 55
                                                      : 35,
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'اضغط للعد',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: isDarkMode
                                                ? Colors.grey.withOpacity(
                                                    0.7,
                                                  )
                                                : AppColors.primaryColor
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                        if (widget.maxCounter != null) ...[
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${cubit.counter}/${widget.maxCounter}',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: isDarkMode
                                                  ? Colors.grey.withOpacity(
                                                      0.5,
                                                    )
                                                  : AppColors.primaryColor
                                                      .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    color: isDarkMode ? Colors.transparent : Colors.white,
                    child: Column(
                      children: [
                        AppButton(
                          horizontalPadding: 30.w,
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            cubit.resetCounter();
                            await saveSebhaCounter(
                              widget.title,
                              cubit.counter,
                              cubit.totalCounter,
                              cubit.cycleCounter,
                            );
                          },
                          title: 'البدء من جديد',
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> saveSebhaCounter(
  String itemText,
  int counter,
  int totalCounter,
  int cycleCounter,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('${itemText}_counter', counter);
  await prefs.setInt('${itemText}_totalCounter', totalCounter);
  await prefs.setInt('${itemText}_cycleCounter', cycleCounter);
}

Future<Map<String, int>> loadSebhaCounter(String itemText) async {
  final prefs = await SharedPreferences.getInstance();
  final counter = prefs.getInt('${itemText}_counter') ?? 0;
  final totalCounter = prefs.getInt('${itemText}_totalCounter') ?? 0;
  final cycleCounter = prefs.getInt('${itemText}_cycleCounter') ?? 0;

  return {
    'counter': counter,
    'totalCounter': totalCounter,
    'cycleCounter': cycleCounter,
  };
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Progress arc
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
