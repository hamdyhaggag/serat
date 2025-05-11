import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/morning_azkar.dart';
import '../services/morning_azkar_service.dart';
import '../Business_Logic/Cubit/azkar_cubit.dart';
import '../Business_Logic/Cubit/azkar_state.dart';
import '../presentation/widgets/azkar/azkar_header.dart';
import '../presentation/widgets/azkar/azkar_title.dart';
import '../presentation/widgets/azkar/azkar_pages.dart';
import '../presentation/widgets/azkar/azkar_progress_indicator.dart';
import '../presentation/widgets/azkar/azkar_dots_indicator.dart';

class MorningAzkarScreen extends StatefulWidget {
  final String title;

  const MorningAzkarScreen({super.key, required this.title});

  @override
  State<MorningAzkarScreen> createState() => _MorningAzkarScreenState();
}

class _MorningAzkarScreenState extends State<MorningAzkarScreen> {
  List<MorningAzkar> _azkar = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAzkar();
    _pageController.addListener(() {
      debugPrint('Page changed to: ${_pageController.page}');
    });
  }

  Future<void> _loadAzkar() async {
    try {
      final azkar = await MorningAzkarService.loadMorningAzkar();
      if (mounted) {
        setState(() {
          _azkar = azkar;
        });
      }
    } catch (e) {
      debugPrint('Error loading morning azkar: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_azkar.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final azkarTexts = _azkar.map((a) => a.title).toList();
    final maxValues = _azkar.map((a) => a.maxValue).toList();

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AzkarCubit, AzkarState>(
          listener: (context, state) {
            final progress = (state.currentIndex + 1) / _azkar.length;
            if (progress == 1.0) {
              // Handle completion
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withAlpha(150),
                      Theme.of(context).primaryColor.withAlpha(100),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26), // 0.1 opacity
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(26), // 0.1 opacity
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AzkarHeader(screenWidth: screenWidth),
                    SizedBox(height: screenHeight * 0.01),
                    AzkarTitle(screenWidth: screenWidth, title: widget.title),
                    SizedBox(height: screenHeight * 0.03),
                    AzkarDotsIndicator(
                      screenWidth: screenWidth,
                      azkar: azkarTexts,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    AzkarPages(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      azkar: azkarTexts,
                      pageController: _pageController,
                      maxValues: maxValues,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    AzkarProgressIndicator(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      azkar: azkarTexts,
                    ),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
