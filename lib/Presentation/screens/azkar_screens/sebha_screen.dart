import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_reset_button.dart'
    show AppButton;
import 'package:serat/Presentation/screens/azkar_screens/SebhaCounterSection.dart'
    show SebhaCounterSection;
import 'package:serat/imports.dart';
import 'package:serat/Business_Logic/Cubit/counter_cubit.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/Presentation/theme/app_theme.dart';

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

    // Use lighter impact for better feel
    HapticFeedback.lightImpact();
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
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [const Color(0xff121212), const Color(0xff1E1E1E)]
                  : [const Color(0xffF8F9FA), const Color(0xffE8F5E9)],
            ),
          ),
          child: BlocBuilder<CounterCubit, CounterState>(
            builder: (context, state) {
              final cubit = CounterCubit.get(context);
              final progress = widget.maxCounter != null
                  ? cubit.counter / widget.maxCounter!
                  : 0.0;

              return ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    SebhaCounterSection(
                      total: cubit.totalCounter,
                      currentCount: cubit.counter,
                      cycleCount: cubit.cycleCounter,
                      beadCount: widget.beadCount,
                      title: widget.title,
                      subtitle: widget.subtitle,
                    )
                        .animate()
                        .fade(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
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
                            // Outer Glow / Shadow
                            Container(
                              width: size.width * 0.75,
                              height: size.width * 0.75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? AppColors.primaryColor
                                            .withOpacity(0.2)
                                        : AppColors.primaryColor
                                            .withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(1000), // Circle
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.white.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (widget.maxCounter != null)
                                          Container(
                                            margin: const EdgeInsets.all(4),
                                            child: CustomPaint(
                                              painter: ProgressPainter(
                                                progress: progress,
                                                color: isDarkMode
                                                    ? AppTheme.secondaryLight
                                                    : AppColors.primaryColor,
                                                strokeWidth: 4,
                                              ),
                                              size: Size.infinite,
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
                                                        (_counterAnimation!
                                                                .value *
                                                            0.1),
                                                    child: Text(
                                                      '${cubit.counter}',
                                                      style: TextStyle(
                                                          fontSize:
                                                              cubit.counter <
                                                                      1000
                                                                  ? 64
                                                                  : 48,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : AppColors
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Cairo', // Consistent font
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                      0, 4),
                                                            )
                                                          ]),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(
                                                'اضغط للعد',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontFamily: 'Cairo',
                                                  color: isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.6)
                                                      : AppColors.primaryColor
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                              if (widget.maxCounter !=
                                                  null) ...[
                                                SizedBox(height: 4.h),
                                                Text(
                                                  '${cubit.counter}/${widget.maxCounter}',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontFamily: 'DIN',
                                                    color: isDarkMode
                                                        ? Colors.white
                                                            .withOpacity(0.4)
                                                        : AppColors.primaryColor
                                                            .withOpacity(0.4),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: 200.ms)
                        .scale(duration: 500.ms, curve: Curves.easeOutBack),
                    SizedBox(height: 30.h),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact(); // Consistent feedback
                          cubit.resetCounter();
                          await saveSebhaCounter(
                            widget.title,
                            cubit.counter,
                            cubit.totalCounter,
                            cubit.cycleCounter,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                          foregroundColor: isDarkMode
                              ? Colors.white
                              : AppColors.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Text(
                          'البدء من جديد',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate(delay: 400.ms).fade().slideY(begin: 0.2, end: 0),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            },
          ),
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
