import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AzkarModelView extends StatefulWidget {
  final String title;
  final List<String> azkarList;
  final List<int> maxValues;
  final VoidCallback? onRetry;

  const AzkarModelView({
    super.key,
    required this.title,
    required this.azkarList,
    required this.maxValues,
    this.onRetry,
  });

  @override
  AzkarModelViewState createState() => AzkarModelViewState();
}

class AzkarModelViewState extends State<AzkarModelView> {
  late ConfettiController _confettiController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
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
            setState(() {});
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient:
                      isDarkMode
                          ? null
                          : const LinearGradient(
                            colors: [Color(0xFF3A6073), Color(0xFF16222A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                ),
                child: Column(
                  children: [
                    AzkarHeader(screenWidth: screenWidth),
                    SizedBox(height: screenHeight * 0.01),
                    AzkarTitle(screenWidth: screenWidth, title: widget.title),
                    SizedBox(height: screenHeight * 0.03),
                    AzkarDotsIndicator(screenWidth: screenWidth, azkar: azkar),
                    SizedBox(height: screenHeight * 0.02),
                    AzkarPages(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      azkar: azkar,
                      pageController: _pageController,
                      maxValues: widget.maxValues,
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
