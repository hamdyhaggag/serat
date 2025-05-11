import 'package:flutter/material.dart';
import '../../data/models/pray_azkar_model.dart';
import '../../data/repositories/pray_azkar_repository.dart';
import 'package:serat/imports.dart';

class PrayAzkarScreen extends StatefulWidget {
  final String? category;
  const PrayAzkarScreen({super.key, this.category});

  @override
  State<PrayAzkarScreen> createState() => _PrayAzkarScreenState();
}

class _PrayAzkarScreenState extends State<PrayAzkarScreen> {
  final PrayAzkarRepository _repository = PrayAzkarRepository();
  PrayAzkarData? _azkarData;
  bool _isLoading = true;
  String? _error;
  final PageController _pageController = PageController();
  final Map<int, bool> _showCheckIcons = {};

  @override
  void initState() {
    super.initState();
    _loadAzkar();
    _pageController.addListener(() {
      debugPrint('Page changed to: ${_pageController.page}');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAzkar() async {
    try {
      final data = await _repository.getPrayAzkar();
      setState(() {
        _azkarData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onShowCheckIcon(int index) {
    setState(() {
      _showCheckIcons[index] = true;
    });
  }

  void _onCheckIconShown(int index) {
    // Handle any additional logic when check icon is shown
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (_azkarData == null) {
      return const Scaffold(body: Center(child: Text('No data available')));
    }

    final categories =
        widget.category != null
            ? {widget.category!: _azkarData!.categories[widget.category]!}
            : _azkarData!.categories;

    final categoryKey = categories.keys.first;
    final category = categories[categoryKey]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final azkarTexts = category.azkar.map((azkar) => azkar.text).toList();
    final maxValues = category.azkar.map((azkar) => azkar.count).toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'أذكار الصلاة'),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => AzkarCubit(),
          child: BlocListener<AzkarCubit, AzkarState>(
            listener: (context, state) {
              final progress = (state.currentIndex + 1) / category.azkar.length;
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
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                      SizedBox(height: screenHeight * 0.08),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
