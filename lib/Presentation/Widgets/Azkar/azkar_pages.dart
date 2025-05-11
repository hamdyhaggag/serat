import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/imports.dart';

class AzkarPages extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<String> azkar;
  final PageController pageController;
  final List<int> maxValues;
  final AzkarState? initialAzkarState;

  const AzkarPages({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.azkar,
    required this.pageController,
    required this.maxValues,
    this.initialAzkarState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Initialize maxValues in the state if not already set
    if (context.read<AzkarCubit>().state.maxValues.isEmpty) {
      final maxValuesMap = Map<int, int>.fromIterables(
        List.generate(maxValues.length, (i) => i),
        maxValues,
      );
      context.read<AzkarCubit>().updateMaxValues(maxValuesMap);
    }

    return Expanded(
      child: PageView.builder(
        controller: pageController,
        itemCount: azkar.length,
        onPageChanged: (index) {
          context.read<AzkarCubit>().updateIndex(index);
        },
        itemBuilder: (context, index) {
          return BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              final completedCards = state.completedCards;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: GestureDetector(
                  onTap: () {
                    if (!completedCards.contains(index)) {
                      context.read<AzkarCubit>().incrementCounter(index);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xff2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Text(
                            azkar[index],
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        AzkarCounter(
                          maxValue: maxValues[index],
                          onComplete: () {
                            context.read<AzkarCubit>().updateCompletedCards(
                              index,
                            );
                          },
                          isCompleted: completedCards.contains(index),
                          pageController: pageController,
                          currentIndex: index,
                          totalPages: azkar.length,
                          onIncrement: () {
                            context.read<AzkarCubit>().incrementCounter(index);
                          },
                        ),
                        if (completedCards.contains(index))
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.02),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: screenWidth * 0.08,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AzkarCounter extends StatefulWidget {
  final int maxValue;
  final VoidCallback onComplete;
  final bool isCompleted;
  final PageController pageController;
  final int currentIndex;
  final int totalPages;
  final VoidCallback onIncrement;

  const AzkarCounter({
    Key? key,
    required this.maxValue,
    required this.onComplete,
    required this.isCompleted,
    required this.pageController,
    required this.currentIndex,
    required this.totalPages,
    required this.onIncrement,
  }) : super(key: key);

  @override
  State<AzkarCounter> createState() => _AzkarCounterState();
}

class _AzkarCounterState extends State<AzkarCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    if (!widget.isCompleted) {
      _controller.forward().then((_) => _controller.reverse());
      widget.onIncrement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentValue = context.select((AzkarCubit cubit) => 
      cubit.state.counters[widget.currentIndex] ?? 0);
    final progress = currentValue / widget.maxValue;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _incrementCounter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isCompleted ? Colors.green : AppColors.primaryColor,
                ),
                strokeWidth: 8,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentValue',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '/${widget.maxValue}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
