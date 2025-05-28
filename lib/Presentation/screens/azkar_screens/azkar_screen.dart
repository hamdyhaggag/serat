import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/Data/services/azkar_service.dart';
import 'package:serat/Data/models/azkar_model.dart';
import 'package:serat/Presentation/Widgets/Azkar/azkar_model_view.dart';
import 'package:serat/Business_Logic/Cubit/azkar_cubit.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

class IconConstants {
  static const IconData morningAzkarIcon = Icons.wb_sunny;
  static const IconData eveningAzkarIcon = Icons.nights_stay;
  static const IconData prayAzkarIcon = Icons.access_alarm;
  static const IconData sleepAzkarIcon = Icons.hotel;
  static const IconData wakeUpAzkarIcon = Icons.wb_sunny;
  static const IconData collectionAzkarIcon = Icons.category;
  static const IconData foodAzkarIcon = Icons.fastfood;
  static const IconData travelAzkarIcon = Icons.flight;
  static const IconData quranAzkarIcon = Icons.book;
  static const IconData nabawiAzkarIcon = Icons.menu_book;
  static const IconData tasabehIcon = Icons.star;
  static const IconData plusAzkarIcon = Icons.add;
  static const IconData deadAzkarIcon = Icons.radio_button_checked;
  static const IconData roqiaIcon = Icons.healing;
}

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  String _lastOpenedTitle = 'أذكار الصباح';
  double _progress = 0.0;
  IconData _lastOpenedIcon = IconConstants.morningAzkarIcon;
  List<AzkarModel> _azkarList = [];
  bool _isLoading = true;

  AzkarState _azkarState = AzkarState(
    currentIndex: 0,
    completedCards: [],
    totalCards: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadState();
    _loadAzkarData();
  }

  Future<void> _loadAzkarData() async {
    try {
      final azkarList = await AzkarService.loadAzkar();
      setState(() {
        _azkarList = azkarList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading Azkar data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastOpenedTitle = prefs.getString('lastOpenedTitle') ?? 'أذكار الصباح';
      _progress = prefs.getDouble('progress') ?? 0.0;

      int iconCode = prefs.getInt('lastOpenedIcon') ??
          IconConstants.morningAzkarIcon.codePoint;
      _lastOpenedIcon = IconData(iconCode, fontFamily: 'MaterialIcons');

      final completedCards = prefs
              .getStringList('completedCards')
              ?.map((e) => int.parse(e))
              .toList() ??
          [];
      _azkarState = AzkarState(
        currentIndex: prefs.getInt('currentIndex') ?? 0,
        completedCards: completedCards,
        totalCards: prefs.getInt('totalCards') ?? 0,
      );
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenedTitle', _lastOpenedTitle);
    await prefs.setDouble('progress', _progress);
    await prefs.setInt('lastOpenedIcon', _lastOpenedIcon.codePoint);

    await prefs.setInt('currentIndex', _azkarState.currentIndex);
    await prefs.setStringList(
      'completedCards',
      _azkarState.completedCards.map((e) => e.toString()).toList(),
    );
    await prefs.setInt('totalCards', _azkarState.totalCards);
  }

  void updateHeader(String title, AzkarState azkarState, IconData icon) {
    setState(() {
      _lastOpenedTitle = title;
      _progress = azkarState.progress;
      _lastOpenedIcon = icon;
      _azkarState = azkarState;
    });
    _saveState().then((_) {
      if (kDebugMode) {
        print('State updated and saved.');
      }
    });
  }

  void _clearProgress() {
    setState(() {
      _progress = 0.0;
      _azkarState = _azkarState.copyWith(completedCards: []);
    });
    _saveState();
  }

  void _navigateToScreen(
    BuildContext context,
    Widget screen,
    AzkarState azkarState,
  ) {
    // If the screen is an AzkarModelView, inject the callback
    Widget targetScreen = screen;
    if (screen is MorningAzkar) {
      targetScreen = MorningAzkar(
        title: (screen as MorningAzkar).title,
        onProgressChanged: (AzkarState newState) {
          setState(() {
            _progress = newState.progress;
            _azkarState = newState;
          });
        },
      );
    }
    // TODO: Repeat for other Azkar screens if needed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => targetScreen,
        settings: RouteSettings(arguments: azkarState),
      ),
    ).then((_) {
      _loadState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                size: 28,
              ),
              onPressed: () async {
                final Zikr? selectedZikr = await showSearch<Zikr?>(
                  context: context,
                  delegate:
                      AzkarSearchDelegate(_azkarList.cast<AzkarScreenItem>())
                          as SearchDelegate<Zikr?>,
                );

                if (selectedZikr != null) {
                  // Find the category that contains this zikr
                  final category = _azkarList.firstWhere(
                    (azkar) => azkar.array.contains(selectedZikr),
                    orElse: () => _azkarList.first,
                  );

                  // Navigate to the category screen and highlight the selected zikr
                  updateHeader(category.category, _azkarState,
                      _getIconForCategory(category.category));
                  _navigateToScreen(
                      context, _buildAzkarScreen(category), _azkarState);
                }
              },
            ),
            Text(
              'الأذكار',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'DIN',
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xff1F1F1F), const Color(0xff2D2D2D)]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16.0),
                      _buildHeaderCard(context),
                      const SizedBox(height: 24.0),
                      _buildGrid(context),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 20.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: _progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  progressColor: Colors.white,
                  barRadius: const Radius.circular(12),
                  padding: EdgeInsets.zero,
                  isRTL: true,
                  animation: true,
                  animateFromLastPercent: true,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _clearProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'مسح التقدم',
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _lastOpenedTitle,
              style: const TextStyle(
                fontFamily: 'DIN',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'نسبة الإكمال',
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'DIN',
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_lastOpenedIcon, color: Colors.white, size: 32.0),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.1,
      ),
      itemCount: _azkarList.length,
      itemBuilder: (context, index) {
        final azkar = _azkarList[index];
        return GestureDetector(
          onTap: () {
            updateHeader(azkar.category, _azkarState,
                _getIconForCategory(azkar.category));
            _navigateToScreen(context, _buildAzkarScreen(azkar), _azkarState);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xff2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForCategory(azkar.category),
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  azkar.category,
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'أذكار الصباح والمساء':
        return IconConstants.morningAzkarIcon;
      case 'أذكار النوم':
        return IconConstants.sleepAzkarIcon;
      // Add more cases for other categories
      default:
        return IconConstants.collectionAzkarIcon;
    }
  }

  Widget _buildAzkarScreen(AzkarModel azkar) {
    final azkarList = azkar.array.map((z) => z.text).toList();
    final maxValues = azkar.array.map((z) => z.count).toList();

    return BlocProvider(
      create: (context) => AzkarCubit(),
      child: Scaffold(
        appBar: CustomAppBar(title: azkar.category),
        body: AzkarModelView(
          title: azkar.category,
          azkarList: azkarList,
          maxValues: maxValues,
          onProgressChanged: (AzkarState newState) {
            updateHeader(
                azkar.category, newState, _getIconForCategory(azkar.category));
          },
        ),
      ),
    );
  }
}
