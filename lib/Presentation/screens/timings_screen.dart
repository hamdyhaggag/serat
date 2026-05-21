import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart' as location;
import 'package:serat/Business_Logic/Cubit/theme_cubit.dart';
// import 'package:serat/Presentation/screens/about/about_screen.dart'
//     show AboutScreen;
import 'package:serat/Presentation/screens/qasas_screen.dart';
import 'package:serat/Presentation/screens/quran_screen.dart';
import 'package:serat/Presentation/screens/radio_screen.dart';
import 'package:serat/Presentation/screens/reciters_screen.dart';
import 'package:serat/Presentation/screens/islamic_quiz_screen.dart';
import 'package:serat/Presentation/screens/history_screen.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/badges/screens/badges_screen.dart';
import 'package:serat/features/prophetic_day/screens/prophetic_day_screen.dart';

import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart' as navigation;
import 'package:serat/Presentation/screens/zakah_calculator_screen.dart';
import 'package:serat/features/quran/routes/quran_routes.dart';
import 'package:serat/features/spiritual_progress/screens/spiritual_dashboard_screen.dart';
import 'dart:math';

import 'package:serat/Features/NamesOfAllah/Presentation/Screens/names_of_allah_screen.dart';
import 'package:serat/shared/constants/app_colors.dart' as shared_colors;
import 'package:serat/Presentation/Widgets/emotional_state_widget.dart';
import 'package:serat/Presentation/screens/about/constants/about_constants.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class TimingsScreen extends StatefulWidget {
  const TimingsScreen({super.key});

  @override
  State<TimingsScreen> createState() => _TimingsScreenState();
}

class _TimingsScreenState extends State<TimingsScreen> {
  StreamSubscription? _navigationSubscription;
  final List<Offset> _particles = [];
  final int _particleCount = 100;
  final Random _random = Random();
  bool _isLoading = true;
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  DateTime? _nextPrayerTime;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _startCountdownTimer();

    // Check if data is already available
    final cubit = location.LocationCubit.get(context);
    if (cubit.timesModel != null) {
      _isLoading = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.getMyCurrentLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add listener to NavigationCubit
    _navigationSubscription =
        context.read<navigation.NavigationCubit>().stream.listen((state) {
      if (state is navigation.ChangeBottomNavState) {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
        }
      }
    });
  }

  void _initializeParticles() {
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Offset(_random.nextDouble() * 400, _random.nextDouble() * 800),
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _navigationSubscription?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _getContextData(bool isDarkMode) {
    final now = DateTime.now();
    final hour = now.hour;
    final isFriday = now.weekday == DateTime.friday;

    if (isFriday && (hour >= 0 && hour <= 23)) {
      // Friday Context
      return {
        'hasContext': true,
        'title': 'يوم الجمعة',
        'subtitle': 'سورة الكهف والصلاة على النبي',
        'icon': Icons.menu_book_rounded,
        'colors': isDarkMode
            ? [const Color(0xff1A2B22), const Color(0xff183025)]
            : [shared_colors.AppColors.primaryColor, const Color(0xff237A57)],
      };
    } else if (hour >= 4 && hour < 9) {
      // Morning Context
      return {
        'hasContext': true,
        'title': 'إشراقة الصباح',
        'subtitle': 'أذكار الصباح تزين يومك',
        'icon': Icons.wb_sunny_rounded,
        'colors': isDarkMode
            ? [const Color(0xff2B231A), const Color(0xff1A1A1A)]
            : [const Color(0xffD39D38), shared_colors.AppColors.primaryColor],
      };
    } else if (hour >= 19 || hour < 4) {
      // Night Context
      return {
        'hasContext': true,
        'title': 'سكون الليل',
        'subtitle': 'أذكار المساء وقيام الليل',
        'icon': Icons.nights_stay_rounded,
        'colors': isDarkMode
            ? [const Color(0xff0A101A), const Color(0xff1A1A1A)]
            : [const Color(0xff2c5364), shared_colors.AppColors.primaryColor],
      };
    } else {
      // Default Context
      return {
        'hasContext': false,
        'colors': isDarkMode
            ? [const Color(0xff1A1A1A), const Color(0xff2D2D2D)]
            : [
                shared_colors.AppColors.primaryColor,
                shared_colors.AppColors.primaryColor.withOpacity(0.8),
              ],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<location.LocationCubit, location.LocationState>(
      listener: (context, state) {
        if (state is location.GetTimingsSuccess) {
          location.LocationCubit.get(context).errorStatus = false;
          if (mounted) {
            setState(() => _isLoading = false);
          }
        } else if (state is location.GetCurrentAddressLoading) {
          if (mounted) {
            setState(() => _isLoading = true);
          }
        }
      },
      builder: (context, state) {
        var locationCubit = location.LocationCubit.get(context);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        // Cache context data once per build to avoid repeated computation
        final contextData = _getContextData(isDarkMode);
        final bool hasContext = contextData['hasContext'] == true;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDarkMode
              ? shared_colors.AppColors.darkBackgroundColor
              : Colors.white,
          drawer: _buildDrawer(isDarkMode),
          endDrawer: _buildDrawer(isDarkMode),
          body: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: EnhancedParticlePainter(
                  particles: _particles,
                  isDarkMode: isDarkMode,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            shared_colors.AppColors.darkBackgroundColor,
                            shared_colors.AppColors.darkBackgroundColor,
                          ]
                        : [
                            Colors.white.withOpacity(0.9),
                            Colors.grey[50]!.withOpacity(0.9),
                          ],
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await locationCubit.getMyCurrentLocation();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Ultra Modern Header
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 380,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: contextData['colors'] as List<Color>,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(40),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDarkMode
                                            ? Colors.black
                                            : shared_colors
                                                .AppColors.primaryColor)
                                        .withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Decorative Circles
                                  Positioned(
                                    top: -50,
                                    right: -50,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                    )
                                        .animate()
                                        .scale(
                                            duration: 2000.ms,
                                            curve: Curves.easeInOut)
                                        .fade(),
                                  ),
                                  Positioned(
                                    bottom: 50,
                                    left: -30,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                    )
                                        .animate()
                                        .scale(
                                            delay: 500.ms,
                                            duration: 2000.ms,
                                            curve: Curves.easeInOut)
                                        .fade(),
                                  ),

                                  SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Top Bar
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.1)),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                      Icons.menu_rounded,
                                                      color: Colors.white),
                                                  onPressed: () => _scaffoldKey
                                                      .currentState
                                                      ?.openDrawer(),
                                                ),
                                              ),

                                              // Location Badge
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.1)),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .location_on_rounded,
                                                        size: 16,
                                                        color: Colors.white
                                                            .withOpacity(0.8)),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        locationCubit.address
                                                                ?.locality ??
                                                            'جاري تحديد الموقع...',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'Cairo', // Ensure custom font
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  .animate()
                                                  .fadeIn()
                                                  .slideY(begin: -0.5),

                                              // Settings/Refresh
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.1)),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                      Icons.refresh_rounded,
                                                      color: Colors.white),
                                                  onPressed: () async {
                                                    setState(() =>
                                                        _isLoading = true);
                                                    await locationCubit
                                                        .getMyCurrentLocation();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          const Spacer(),

                                          // Main Countdown Centerpiece
                                          Column(
                                            children: [
                                              Text(
                                                'الصلاة القادمة',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 16,
                                                  fontFamily: 'Cairo',
                                                  letterSpacing: 1.2,
                                                ),
                                              )
                                                  .animate()
                                                  .fadeIn()
                                                  .slideY(begin: 0.2),
                                              const SizedBox(height: 8),
                                              Text(
                                                _nextPrayerName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Cairo',
                                                  height: 1,
                                                ),
                                              ).animate().fadeIn().scale(),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.2)),
                                                ),
                                                child: Text(
                                                  _formatCountdown(
                                                      _timeUntilNextPrayer),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        'DIN', // Use DIN for numbers
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              )
                                                  .animate()
                                                  .fadeIn(delay: 300.ms)
                                                  .shimmer(duration: 2000.ms),
                                            ],
                                          ),
                                          const Spacer(),

                                          // Date Info
                                          Text(
                                            locationCubit.timesModel != null
                                                ? '${locationCubit.timesModel!.data.date.hijri.day} ${locationCubit.timesModel!.data.date.hijri.month.ar} ${locationCubit.timesModel!.data.date.hijri.year}'
                                                : DateFormat(
                                                        'd MMMM yyyy', 'ar')
                                                    .format(DateTime.now()),
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 14,
                                              fontFamily: 'Cairo',
                                            ),
                                          ).animate().fadeIn(delay: 500.ms),
                                          const SizedBox(
                                              height:
                                                  40), // Space for floating card
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Floating Glass Prayer List
                            Positioned(
                              bottom: -60,
                              left: 20,
                              right: 20,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    height:
                                        140, // Fixed height for horizontal list
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? const Color(0xff252525)
                                              .withOpacity(0.85)
                                          : Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.white.withOpacity(0.4),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: _isLoading
                                        ? _buildSkeletonPrayerTimes()
                                        : ListView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 20),
                                            children: [
                                              if (locationCubit.timesModel !=
                                                  null) ...[
                                                _buildModernPrayerItem(
                                                    'الفجر',
                                                    locationCubit.timesModel!
                                                        .data.timings.fajr,
                                                    isDarkMode,
                                                    _isNextPrayer('الفجر',
                                                        locationCubit)),
                                                _buildModernPrayerItem(
                                                    'الشروق',
                                                    locationCubit.timesModel!
                                                        .data.timings.sunrise,
                                                    isDarkMode,
                                                    _isNextPrayer('الشروق',
                                                        locationCubit)),
                                                _buildModernPrayerItem(
                                                    'الظهر',
                                                    locationCubit.timesModel!
                                                        .data.timings.dhuhr,
                                                    isDarkMode,
                                                    _isNextPrayer('الظهر',
                                                        locationCubit)),
                                                _buildModernPrayerItem(
                                                    'العصر',
                                                    locationCubit.timesModel!
                                                        .data.timings.asr,
                                                    isDarkMode,
                                                    _isNextPrayer('العصر',
                                                        locationCubit)),
                                                _buildModernPrayerItem(
                                                    'المغرب',
                                                    locationCubit.timesModel!
                                                        .data.timings.maghrib,
                                                    isDarkMode,
                                                    _isNextPrayer('المغرب',
                                                        locationCubit)),
                                                _buildModernPrayerItem(
                                                    'العشاء',
                                                    locationCubit.timesModel!
                                                        .data.timings.isha,
                                                    isDarkMode,
                                                    _isNextPrayer('العشاء',
                                                        locationCubit)),
                                              ]
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),

                        const SizedBox(height: 80),
                        if (hasContext) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              onTap: () {
                                if (contextData['title'] == 'يوم الجمعة') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const QuranScreen(initialPage: 293)),
                                  );
                                } else {
                                  navigation.NavigationCubit.get(context)
                                      .changeIndex(2); // Go to Azkar tab
                                }
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [
                                            const Color(0xff2A2A2A),
                                            const Color(0xff222222)
                                          ]
                                        : [
                                            (contextData['colors']
                                                    as List<Color>)[0]
                                                .withOpacity(0.08),
                                            (contextData['colors']
                                                    as List<Color>)[1]
                                                .withOpacity(0.08),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : (contextData['colors']
                                                as List<Color>)[0]
                                            .withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.2)
                                          : (contextData['colors']
                                                  as List<Color>)[0]
                                              .withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.05)
                                            : (contextData['colors']
                                                    as List<Color>)[0]
                                                .withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        contextData['icon'] as IconData,
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.9)
                                            : (contextData['colors']
                                                as List<Color>)[0],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contextData['title'] as String,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : const Color(0xff1B1B1B),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            contextData['subtitle'] as String,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : const Color(0xff555555),
                                              fontSize: 13,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: isDarkMode
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),
                        ],

                        EmotionalStateWidget(isDarkMode: isDarkMode),
                        const SizedBox(height: 28),

                        // ── Featured Card: مركز العبادات ──────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SpiritualDashboardScreen())),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    shared_colors.AppColors.primaryColor,
                                    Color(0xff237A57),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: shared_colors.AppColors.primaryColor
                                        .withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: Colors.white,
                                        size: 30),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const AppText(
                                          'مركـز العبـادات',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                        ),
                                        const SizedBox(height: 4),
                                        AppText(
                                          'تتبع مهامك وإحصائياتك اليومية',
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: 'Cairo',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.1, end: 0),
                        ),
                        const SizedBox(height: 32),

                        // ── Section: القرآن والذكر ────────────────────────────────
                        _buildSectionHeader('القرآن والذكر',
                            Icons.menu_book_rounded, isDarkMode),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildHorizontalCard(
                                  'القرآن الكريم',
                                  Icons.menu_book_rounded,
                                  const Color(0xff1E6B4A),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const QuranScreen()))),
                              _buildHorizontalCard(
                                  'القراء',
                                  Icons.record_voice_over_rounded,
                                  const Color(0xff2980B9),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RecitersScreen()))),
                              _buildHorizontalCard(
                                  'الراديو',
                                  Icons.radio_rounded,
                                  const Color(0xffC0392B),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RadioScreen()))),
                              _buildHorizontalCard(
                                  'بطاقات القرآن',
                                  Icons.style_rounded,
                                  const Color(0xff4A28A0),
                                  isDarkMode,
                                  onTap: () => Navigator.pushNamed(
                                      context, QuranRoutes.surahList)),
                              _buildHorizontalCard(
                                  'أسماء الله الحسنى',
                                  Icons.verified_rounded,
                                  const Color(0xffB8860B),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const NamesOfAllahScreen()))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Section: التطور الإيماني ──────────────────────────────
                        _buildSectionHeader('التطور الإيماني',
                            Icons.military_tech_rounded, isDarkMode),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.15,
                            children: [
                              _buildFeatureCard('الأوسمة النبوية',
                                  Icons.military_tech_rounded, isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const BadgesScreen()))),
                              _buildFeatureCard('اليوم النبوي',
                                  Icons.av_timer_rounded, isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => PropheticDayScreen(
                                              isDarkMode: isDarkMode)))),
                              _buildFeatureCard('اختبار إسلامي',
                                  Icons.quiz_rounded, isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const IslamicQuizScreen()))),
                              _buildFeatureCard('روائع القصص',
                                  Icons.auto_stories_rounded, isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const QasasScreen()))),
                            ],
                          )
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideY(begin: 0.1, end: 0),
                        ),
                        const SizedBox(height: 32),

                        // ── Section: المعرفة الإسلامية ────────────────────────────
                        _buildSectionHeader('المعرفة الإسلامية',
                            Icons.history_edu_rounded, isDarkMode),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildListTileCard(
                                  'التاريخ الإسلامي',
                                  'استكشف الحضارة الإسلامية عبر القرون',
                                  Icons.history_rounded,
                                  const Color(0xff8B4513),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const HistoryScreen()))),
                              const SizedBox(height: 12),
                              _buildListTileCard(
                                  'حاسبة الزكاة',
                                  'احسب زكاتك بسهولة واحترافية',
                                  Icons.calculate_rounded,
                                  const Color(0xff1E6B4A),
                                  isDarkMode,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ZakahCalculatorScreen()))),
                            ],
                          )
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .slideY(begin: 0.1, end: 0),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonPrayerTimes() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:
          isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[300]!,
      highlightColor:
          isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[100]!,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernPrayerItem(
    String name,
    String time,
    bool isDarkMode,
    bool isNext,
  ) {
    final prayerTime = _parsePrayerTime(time);

    return Container(
      width: 70, // Slightly narrower for better fit usually
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Compact
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext
                  ? (isDarkMode
                      ? Colors.white
                      : shared_colors.AppColors.primaryColor)
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05)),
              shape: BoxShape.circle,
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: (isDarkMode
                                ? Colors.white
                                : shared_colors.AppColors.primaryColor)
                            .withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              _getPrayerIcon(name),
              color: isNext
                  ? (isDarkMode ? Colors.black : Colors.white)
                  : (isDarkMode ? Colors.white70 : Colors.black54),
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),

          const SizedBox(height: 2),

          // Time
          Text(
            _formatTime12Hour(prayerTime),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isNext
                  ? (isDarkMode
                      ? Colors.white70
                      : shared_colors.AppColors.primaryColor.withOpacity(0.8))
                  : (isDarkMode ? Colors.white38 : Colors.black38),
              fontFamily: 'DIN',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    ).animate(target: isNext ? 1 : 0).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.1, 1.1),
        duration: 300.ms);
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: shared_colors.AppColors.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                color: shared_colors.AppColors.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDarkMode ? Colors.white : const Color(0xff1B1B2F),
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: shared_colors.AppColors.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(
    String title,
    IconData icon,
    Color color,
    bool isDarkMode, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.07)
                : color.withOpacity(0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xff2d3436),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 350.ms)
          .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),
    );
  }

  Widget _buildListTileCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkMode, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : color.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                            isDarkMode ? Colors.white : const Color(0xff1B1B2F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: isDarkMode ? Colors.white38 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_rounded,
                  size: 15,
                  color: isDarkMode ? Colors.white30 : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    bool isDarkMode, {
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor:
                  shared_colors.AppColors.primaryColor.withOpacity(0.1),
              highlightColor:
                  shared_colors.AppColors.primaryColor.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xff2A2A2A).withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.6),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? shared_colors.AppColors.primaryColor
                                .withOpacity(0.15)
                            : shared_colors.AppColors.primaryColor
                                .withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: shared_colors.AppColors.primaryColor
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: shared_colors.AppColors.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : const Color(0xff2d3436),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut);
  }

  DateTime _parsePrayerTime(String time) {
    try {
      final now = DateTime.now();
      // Remove any suffix like " (EET)"
      final cleanTime = time.split(' ')[0];
      final timeParts = cleanTime.split(':');
      if (timeParts.length < 2) return now;

      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0].trim()),
        int.parse(timeParts[1].trim()),
      );
    } catch (e) {
      debugPrint('Error parsing prayer time: $time - $e');
      return DateTime.now();
    }
  }

  String _formatTime12Hour(DateTime time) {
    try {
      final arabicTime = DateFormat('hh:mm a', 'ar').format(time);
      return arabicTime.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    } catch (e) {
      return time.toString();
    }
  }

  bool _isNextPrayer(String prayerName, location.LocationCubit locationCubit) {
    final timings = locationCubit.timesModel!.data.timings;
    final now = DateTime.now();

    DateTime fajrTime = _parsePrayerTime(timings.fajr);
    DateTime sunriseTime = _parsePrayerTime(timings.sunrise);
    DateTime dhuhrTime = _parsePrayerTime(timings.dhuhr);
    DateTime asrTime = _parsePrayerTime(timings.asr);
    DateTime maghribTime = _parsePrayerTime(timings.maghrib);
    DateTime ishaTime = _parsePrayerTime(timings.isha);

    if (now.isAfter(ishaTime)) {
      fajrTime = fajrTime.add(const Duration(days: 1));
    }

    String nextPrayer = '';
    if (now.isBefore(fajrTime)) {
      nextPrayer = 'الفجر';
    } else if (now.isBefore(sunriseTime)) {
      nextPrayer = 'الشروق';
    } else if (now.isBefore(dhuhrTime)) {
      nextPrayer = 'الظهر';
    } else if (now.isBefore(asrTime)) {
      nextPrayer = 'العصر';
    } else if (now.isBefore(maghribTime)) {
      nextPrayer = 'المغرب';
    } else if (now.isBefore(ishaTime)) {
      nextPrayer = 'العشاء';
    } else {
      nextPrayer = 'الفجر';
    }

    return prayerName == nextPrayer;
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny_outlined;
      case 'الظهر':
        return Icons.sunny;
      case 'العصر':
        return Icons.sunny_snowing;
      case 'المغرب':
        return Icons.nightlight_round;
      case 'العشاء':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildDrawer(bool isDarkMode) {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        shared_colors.AppColors.primaryColor.withOpacity(0.8),
                        shared_colors.AppColors.primaryColor.withOpacity(0.4),
                      ]
                    : [
                        shared_colors.AppColors.primaryColor,
                        shared_colors.AppColors.primaryColor.withOpacity(0.7),
                      ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: DrawerHeaderPatternPainter(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row with logo and app name
                        Row(
                          children: [
                            // App Logo with animation
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/logo.webp',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // App Name and description in a column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // App Name with gradient text
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: const AppText(
                                      'تطبيق صراط',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // App Description
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const AppText(
                                      'تطبيق إسلامي شامل',
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Version info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 3),
                              AppText(
                                'الإصدار 1.0.0',
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSection(
                  title: 'الإعدادات',
                  items: [
                    _buildDrawerItem(
                      icon: Icons.timer,
                      title: ' تحديد مواقيت الصلاة',
                      onTap: () => showMethods(context),
                      isDarkMode: isDarkMode,
                    ),
                    // _buildDrawerItem(
                    //   icon: Icons.mosque_outlined,
                    //   title: 'إعدادات المؤذن',
                    //   onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const AdhanSettingsScreen(),
                    //     ),
                    //   ),
                    //   isDarkMode: isDarkMode,
                    // ),
                    _buildDrawerItem(
                      icon: Icons.brightness_6,
                      title: 'المظهر',
                      subtitle: isDarkMode ? 'الوضع الليلي' : 'الوضع النهاري',
                      onTap: () {
                        ThemeCubit.get(context)
                            .changeAppMode(isLight: !isDarkMode);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerSection(
                  title: 'عن التطبيق',
                  items: [
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      title: 'حول التطبيق',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppInfo(),
                        ),
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.share,
                      title: 'مشاركة التطبيق',
                      onTap: () => _shareApp(),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.star,
                      title: 'تقييم التطبيق',
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.serat.app.serat',
                        ),
                      ),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection({
    required String title,
    required List<Widget> items,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: AppText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            shared_colors.AppColors.primaryColor
                                .withOpacity(0.3),
                            shared_colors.AppColors.primaryColor
                                .withOpacity(0.1),
                          ]
                        : [
                            shared_colors.AppColors.primaryColor
                                .withOpacity(0.2),
                            shared_colors.AppColors.primaryColor
                                .withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color:
                          shared_colors.AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isDarkMode
                      ? Colors.white
                      : shared_colors.AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white
                          : shared_colors.AppColors.primaryColor,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      AppText(
                        subtitle,
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      AboutConstants.shareMessage,
    );
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _updateTimeUntilNextPrayer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTimeUntilNextPrayer();
        });
      }
    });
  }

  void _updateTimeUntilNextPrayer() {
    final locationCubit = location.LocationCubit.get(context);
    if (locationCubit.timesModel == null) return;

    final timings = locationCubit.timesModel!.data.timings;
    final now = DateTime.now();

    DateTime fajrTime = _parsePrayerTime(timings.fajr);
    DateTime sunriseTime = _parsePrayerTime(timings.sunrise);
    DateTime dhuhrTime = _parsePrayerTime(timings.dhuhr);
    DateTime asrTime = _parsePrayerTime(timings.asr);
    DateTime maghribTime = _parsePrayerTime(timings.maghrib);
    DateTime ishaTime = _parsePrayerTime(timings.isha);

    if (now.isAfter(ishaTime)) {
      fajrTime = fajrTime.add(const Duration(days: 1));
      sunriseTime = sunriseTime.add(const Duration(days: 1));
      dhuhrTime = dhuhrTime.add(const Duration(days: 1));
      asrTime = asrTime.add(const Duration(days: 1));
      maghribTime = maghribTime.add(const Duration(days: 1));
      ishaTime = ishaTime.add(const Duration(days: 1));
    }

    if (now.isBefore(fajrTime)) {
      _nextPrayerTime = fajrTime;
      _nextPrayerName = 'الفجر';
    } else if (now.isBefore(sunriseTime)) {
      _nextPrayerTime = sunriseTime;
      _nextPrayerName = 'الشروق';
    } else if (now.isBefore(dhuhrTime)) {
      _nextPrayerTime = dhuhrTime;
      _nextPrayerName = 'الظهر';
    } else if (now.isBefore(asrTime)) {
      _nextPrayerTime = asrTime;
      _nextPrayerName = 'العصر';
    } else if (now.isBefore(maghribTime)) {
      _nextPrayerTime = maghribTime;
      _nextPrayerName = 'المغرب';
    } else if (now.isBefore(ishaTime)) {
      _nextPrayerTime = ishaTime;
      _nextPrayerName = 'العشاء';
    } else {
      _nextPrayerTime = fajrTime;
      _nextPrayerName = 'الفجر';
    }

    _timeUntilNextPrayer = _nextPrayerTime!.difference(now);
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}

class EnhancedParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final bool isDarkMode;

  EnhancedParticlePainter({required this.particles, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(0.15)
          : shared_colors.AppColors.primaryColor.withOpacity(0.15)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var particle in particles) {
      canvas.drawCircle(particle, 2, paint);
      canvas.drawCircle(
        particle,
        1,
        paint..color = paint.color.withOpacity(0.5),
      );
      canvas.drawCircle(
        particle,
        0.5,
        paint..color = paint.color.withOpacity(0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawerHeaderPatternPainter extends CustomPainter {
  final Color color;

  DrawerHeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    for (int i = -size.width.toInt(); i < size.width.toInt(); i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + size.height, size.height),
        paint,
      );
    }

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (i + 1) / 6,
          size.height * (i + 1) / 6,
        ),
        20,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
