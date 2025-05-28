import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serat/presentation/widgets/azkar/azkar_pages.dart';

class AzkarModelView extends StatefulWidget {
  final String title;
  final List<String> azkarList;
  final List<int> maxValues;
  final VoidCallback? onRetry;
  final AzkarState? initialAzkarState;
  final void Function(AzkarState)? onProgressChanged;

  const AzkarModelView({
    super.key,
    required this.title,
    required this.azkarList,
    required this.maxValues,
    this.onRetry,
    this.initialAzkarState,
    this.onProgressChanged,
  });

  @override
  AzkarModelViewState createState() => AzkarModelViewState();
}

class AzkarModelViewState extends State<AzkarModelView> {
  late ConfettiController _confettiController;
  late PageController _pageController;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _pageController = PageController(
      initialPage: widget.initialAzkarState?.currentIndex ?? 0,
    );
    _loadAzkarState().then((state) {
      if (mounted) {
        context.read<AzkarCubit>().emit(state);
        // Show dialog if there's cached progress
        if (!_hasShownDialog && state.cachedProgress > 0) {
          _showContinueDialog(state);
        }
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveAzkarState(AzkarState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', state.currentIndex);
    await prefs.setStringList(
      'completedCards',
      state.completedCards.map((e) => e.toString()).toList(),
    );
    await prefs.setInt('totalCards', state.totalCards);
    await prefs.setDouble('cachedProgress', state.cachedProgress);

    // Save counters
    final countersJson =
        state.counters.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('counters', countersJson);

    // Save max values
    final maxValuesJson =
        state.maxValues.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('maxValues', maxValuesJson);
  }

  Future<AzkarState> _loadAzkarState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt('currentIndex') ?? 0;
    final completedCards = (prefs.getStringList('completedCards') ?? [])
        .map((e) => int.parse(e))
        .toList();
    final totalCards = prefs.getInt('totalCards') ?? 0;
    final cachedProgress = prefs.getDouble('cachedProgress') ?? 0.0;

    // Load counters
    final countersJson = prefs.getStringList('counters') ?? [];
    final counters = Map<int, int>.fromEntries(
      countersJson.map((e) {
        final parts = e.split(':');
        return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
      }),
    );

    // Load max values
    final maxValuesJson = prefs.getStringList('maxValues') ?? [];
    final maxValues = Map<int, int>.fromEntries(
      maxValuesJson.map((e) {
        final parts = e.split(':');
        return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
      }),
    );

    return AzkarState(
      currentIndex: currentIndex,
      completedCards: completedCards,
      totalCards: totalCards,
      cachedProgress: cachedProgress,
      counters: counters,
      maxValues: maxValues,
    );
  }

  Future<void> _showContinueDialog(AzkarState state) async {
    if (!mounted) return;

    _hasShownDialog = true;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AzkarCubit>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xff2C2C2C) : Colors.white,
          title: Text(
            'استمرار الأذكار',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'DIN',
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل تريد الاستمرار من حيث توقفت أم البدء من جديد؟',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 16,
              fontFamily: 'DIN',
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    cubit.resetProgress();
                    _pageController.jumpToPage(0);
                  },
                  child: Text(
                    'بدء من جديد',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 16,
                      fontFamily: 'DIN',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Find the last completed adhkar index
                    final lastCompletedIndex = state.completedCards.isEmpty
                        ? 0
                        : state.completedCards.reduce((a, b) => a > b ? a : b);
                    // Update the page controller to the next uncompleted adhkar
                    _pageController.jumpToPage(lastCompletedIndex + 1);
                    // Update the cubit state to match
                    cubit.updateIndex(lastCompletedIndex + 1);
                  },
                  child: Text(
                    'استمرار',
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 16,
                      fontFamily: 'DIN',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final azkar = widget.azkarList;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (azkar.isEmpty) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لا توجد أذكار متاحة',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                if (widget.onRetry != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onRetry,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      body: SafeArea(
        child: BlocListener<AzkarCubit, AzkarState>(
          listener: (context, state) {
            final progress = (state.currentIndex + 1) / azkar.length;
            if (progress == 1.0) {
              _confettiController.play();
            }
            _saveAzkarState(state);
            if (widget.onProgressChanged != null) {
              widget.onProgressChanged!(state);
            }
            setState(() {});
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF2D2D2D),
                            Color(0xFF1A1A1A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.5, 1.0],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFFF8F9FA),
                            Color(0xFFE9ECEF),
                            Color(0xFFF8F9FA),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.5, 1.0],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    AzkarDotsIndicator(screenWidth: screenWidth, azkar: azkar),
                    SizedBox(height: screenHeight * 0.02),
                    AzkarPages(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      azkar: azkar,
                      pageController: _pageController,
                      maxValues: widget.maxValues,
                      initialAzkarState: widget.initialAzkarState,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    AzkarProgressIndicator(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      azkar: azkar,
                    ),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
