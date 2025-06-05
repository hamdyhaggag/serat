import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart' as location;
import 'package:serat/Business_Logic/Cubit/theme_cubit.dart';
import 'package:serat/Presentation/screens/qasas_screen.dart';
import 'package:serat/Presentation/screens/quran_screen.dart';
import 'package:serat/Presentation/screens/radio_screen.dart';
import 'package:serat/Presentation/screens/reciters_screen.dart';
import 'package:serat/Presentation/screens/about_screen.dart';
import 'package:serat/Presentation/screens/islamic_quiz_screen.dart';
import 'package:serat/imports.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart' as navigation;
import 'package:serat/Presentation/screens/dailygoal_screens/daily_goal_navigation_screen.dart';
import 'package:serat/Presentation/screens/zakah_calculator_screen.dart';
import 'package:serat/features/quran/routes/quran_routes.dart';
import 'dart:math';
import 'dart:async';
import 'package:serat/Data/Model/times_model.dart';
import 'dart:developer' as developer;

class TimingsScreen extends StatefulWidget {
  const TimingsScreen({super.key});

  @override
  State<TimingsScreen> createState() => _TimingsScreenState();
}

class _TimingsScreenState extends State<TimingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _initializeParticles();
    _startCountdownTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      location.LocationCubit.get(context).getMyCurrentLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add listener to NavigationCubit
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
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff2F2F2F)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonPrayerTimes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff2F2F2F)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(6, (index) => _buildSkeletonPrayerTime()),
        ],
      ),
    );
  }

  Widget _buildSkeletonPrayerTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
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

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
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
                            const Color(0xff1F1F1F).withOpacity(0.9),
                            const Color(0xff2F2F2F).withOpacity(0.9),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDarkMode
                                  ? [
                                      const Color(0xff1F1F1F),
                                      const Color(0xff2F2F2F),
                                    ]
                                  : [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withOpacity(0.8),
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.menu,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              onPressed: () {
                                                _scaffoldKey.currentState
                                                    ?.openDrawer();
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (_isLoading)
                                                    Container(
                                                      width: 120,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    )
                                                  else
                                                    const AppText(
                                                      'السلام عليكم',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  const SizedBox(height: 2),
                                                  if (_isLoading)
                                                    Container(
                                                      width: 200,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    )
                                                  else if (locationCubit
                                                          .timesModel !=
                                                      null)
                                                    AppText(
                                                      '${locationCubit.timesModel!.data.date.hijri.weekday.ar} ${locationCubit.timesModel!.data.date.hijri.day} ${locationCubit.timesModel!.data.date.hijri.month.ar} ${locationCubit.timesModel!.data.date.hijri.year}',
                                                      fontSize: 14,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    )
                                                  else
                                                    AppText(
                                                      DateFormat('EEEE, d MMMM',
                                                              'ar')
                                                          .format(
                                                              DateTime.now()),
                                                      fontSize: 14,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (_isLoading)
                                    Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  locationCubit.address
                                                              ?.locality !=
                                                          null
                                                      ? _translateLocationToArabic(
                                                          locationCubit.address!
                                                              .locality)
                                                      : 'جاري تحديد الموقع...',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (locationCubit.address
                                                        ?.administrativeArea !=
                                                    null)
                                                  AppText(
                                                    _translateLocationToArabic(
                                                        locationCubit.address!
                                                            .administrativeArea),
                                                    fontSize: 12,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.refresh,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              setState(() => _isLoading = true);
                                              await locationCubit
                                                  .getMyCurrentLocation();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildSkeletonPrayerTimes(),
                            ),
                          )
                        else if (locationCubit.timesModel != null)
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xff2F2F2F)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        'مواقيت الصلاة',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : AppColors.primaryColor,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : AppColors.primaryColor
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                AppText(
                                                  'متبقي حتى $_nextPrayerName',
                                                  fontSize: 12,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : AppColors.primaryColor,
                                                ),
                                                AppText(
                                                  _formatCountdown(
                                                      _timeUntilNextPrayer),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : AppColors.primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildPrayerTimeItem(
                                          'الفجر',
                                          locationCubit
                                              .timesModel!.data.timings.fajr,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'الفجر', locationCubit),
                                        ),
                                        _buildPrayerTimeItem(
                                          'الشروق',
                                          locationCubit
                                              .timesModel!.data.timings.sunrise,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'الشروق', locationCubit),
                                        ),
                                        _buildPrayerTimeItem(
                                          'الظهر',
                                          locationCubit
                                              .timesModel!.data.timings.dhuhr,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'الظهر', locationCubit),
                                        ),
                                        _buildPrayerTimeItem(
                                          'العصر',
                                          locationCubit
                                              .timesModel!.data.timings.asr,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'العصر', locationCubit),
                                        ),
                                        _buildPrayerTimeItem(
                                          'المغرب',
                                          locationCubit
                                              .timesModel!.data.timings.maghrib,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'المغرب', locationCubit),
                                        ),
                                        _buildPrayerTimeItem(
                                          'العشاء',
                                          locationCubit
                                              .timesModel!.data.timings.isha,
                                          isDarkMode,
                                          isNext: _isNextPrayer(
                                              'العشاء', locationCubit),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Transform.translate(
                          offset: const Offset(0, -60),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isLoading)
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1.2,
                                    children: List.generate(
                                      4,
                                      (index) => _buildSkeletonCard(),
                                    ),
                                  )
                                else
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1.2,
                                    children: [
                                      _buildFeatureCard(
                                        'الهدف اليومي',
                                        Icons.flag,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const DailyGoalNavigationScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'القرآن الكريم',
                                        Icons.menu_book,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const QuranScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'بطاقات القرآن',
                                        Icons.book,
                                        isDarkMode,
                                        onTap: () => Navigator.pushNamed(
                                            context, QuranRoutes.surahList),
                                      ),
                                      _buildFeatureCard(
                                        'القراء',
                                        Icons.record_voice_over,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RecitersScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'الراديو',
                                        Icons.radio,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RadioScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'روائع القصص',
                                        Icons.auto_stories,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const QasasScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'حاسبة الزكاة',
                                        Icons.calculate,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ZakahCalculatorScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildFeatureCard(
                                        'اختبار إسلامي',
                                        Icons.quiz,
                                        isDarkMode,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const IslamicQuizScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildPrayerTimeItem(
    String name,
    String time,
    bool isDarkMode, {
    bool isNext = false,
  }) {
    final prayerTime = _parsePrayerTime(time);
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isNext
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.primaryColor.withOpacity(0.2),
                        AppColors.primaryColor.withOpacity(0.1),
                      ]
                    : [
                        AppColors.primaryColor.withOpacity(0.15),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
              )
            : null,
        color: isNext ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.primaryColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.primaryColor.withOpacity(0.3),
                        AppColors.primaryColor.withOpacity(0.1),
                      ]
                    : [
                        AppColors.primaryColor.withOpacity(0.2),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(name),
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            name,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
          const SizedBox(height: 4),
          AppText(
            _formatTime12Hour(prayerTime),
            fontSize: 12,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    bool isDarkMode, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xff2F2F2F), const Color(0xff252525)]
                : [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          AppColors.primaryColor.withOpacity(0.3),
                          AppColors.primaryColor.withOpacity(0.1),
                        ]
                      : [
                          AppColors.primaryColor.withOpacity(0.2),
                          AppColors.primaryColor.withOpacity(0.05),
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parsePrayerTime(String time) {
    final now = DateTime.now();
    final timeParts = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
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
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        AppColors.primaryColor.withOpacity(0.8),
                        AppColors.primaryColor.withOpacity(0.4),
                      ]
                    : [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Logo with animation
                          Hero(
                            tag: 'app_logo',
                            child: Container(
                              padding: const EdgeInsets.all(15),
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
                                'assets/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // App Description
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const AppText(
                              'تطبيق إسلامي شامل',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Version info
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  'الإصدار 1.0.0',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                      title: 'طريقة تحديد مواقيت الصلاة',
                      onTap: () => showMethods(context),
                      isDarkMode: isDarkMode,
                    ),
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
                          builder: (context) => const AboutScreen(),
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
                      icon: Icons.code,
                      title: 'تطوير التطبيق',
                      onTap: () =>
                          launchUrl(Uri.parse('https://github.com/serat')),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.star,
                      title: 'تقييم التطبيق',
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.serat.app',
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
                            AppColors.primaryColor.withOpacity(0.3),
                            AppColors.primaryColor.withOpacity(0.1),
                          ]
                        : [
                            AppColors.primaryColor.withOpacity(0.2),
                            AppColors.primaryColor.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
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
                      color: isDarkMode ? Colors.white : AppColors.primaryColor,
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
      'تطبيق صراط هو تطبيق إسلامي شامل يحتوي على العديد من المميزات مثل:\n\n'
      '• مواقيت الصلاة\n'
      '• اتجاه القبلة\n'
      '• الأذكار الصباحية والمسائية\n'
      '• الأربعين النووية\n'
      '• السبحة الإلكترونية\n'
      '• القرآن الكريم مع التفسير\n'
      '• القراء المشهورين\n'
      '• الراديو الإسلامي\n'
      '• التقويم الهجري\n'
      '• حاسبة الزكاة\n'
      '• الهدف اليومي\n'
      '• التنبيهات والإشعارات\n'
      '• الوضع الليلي\n'
      '• دعم اللغة العربية\n\n'
      'تحميل التطبيق من هنا:\n'
      'https://play.google.com/store/apps/details?id=com.serat.app',
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

  String _translateLocationToArabic(String? location) {
    if (location == null) return '';

    final Map<String, String> cities = {
      'At Tamamah': 'التمامة',
      'Cairo': 'القاهرة',
      'Alexandria': 'الإسكندرية',
      'Giza': 'الجيزة',
      'Shubra El Kheima': 'شبرا الخيمة',
      'Port Said': 'بورسعيد',
      'Suez': 'السويس',
      'Luxor': 'الأقصر',
      'Mansoura': 'المنصورة',
      'Tanta': 'طنطا',
      'Asyut': 'أسيوط',
      'Ismailia': 'الإسماعيلية',
      'Fayyum': 'الفيوم',
      'Zagazig': 'الزقازيق',
      'Aswan': 'أسوان',
      'Damietta': 'دمياط',
      'Damanhur': 'دمنهور',
      'Minya': 'المنيا',
      'Beni Suef': 'بني سويف',
      'Sohag': 'سوهاج',
      'Hurghada': 'الغردقة',
      '6th of October City': 'مدينة 6 أكتوبر',
      'Sharm El Sheikh': 'شرم الشيخ',
      'New Cairo': 'القاهرة الجديدة',
      'Sheikh Zayed City': 'مدينة الشيخ زايد',
      'Madinat Nasr': 'مدينة نصر',
      'Heliopolis': 'مصر الجديدة',
      'Maadi': 'المعادي',
      'Garden City': 'جاردن سيتي',
      'Dokki': 'الدقي',
      'Mohandessin': 'المهندسين',
      'Agouza': 'العجوزة',
      'Zamalek': 'الزمالك',
      'Helwan': 'حلوان',
      'Shubra': 'شبرا',
      'Rod El Farag': 'روض الفرج',
      'Ain Shams': 'عين شمس',
      'El Marg': 'المرج',
      'El Matareya': 'المطرية',
      'El Rehab': 'الرحاب',
      'El Tagamo\'': 'التجمع',
      'El Obour': 'العبور',
      'El Shorouk': 'الشروق',
      'Badr City': 'مدينة بدر',
      'New Capital': 'العاصمة الإدارية',
      'Sadat City': 'مدينة السادات',
      '10th of Ramadan City': 'مدينة العاشر من رمضان',
      'El Mahalla El Kubra': 'المحلة الكبرى',
      'Kafr El Sheikh': 'كفر الشيخ',
      'El Arish': 'العريش',
      'Rafah': 'رفح',
      'El Tor': 'الطور',
      'Saint Catherine': 'سانت كاترين',
      'Dahab': 'دهب',
      'Nuweiba': 'نويبع',
      'Taba': 'طابا',
      'El Quseir': 'القصير',
      'Marsa Alam': 'مرسى علم',
      'Safaga': 'سفاجا',
      'El Gouna': 'الجونة',
      'Soma Bay': 'سوما باي',
      'Makadi Bay': 'مكادي باي',
      'Sahl Hasheesh': 'سهل حشيش',
      'El Ain El Sokhna': 'العين السخنة',
      'Ras Gharib': 'رأس غارب',
      'Ras Shukheir': 'رأس شقير',
      'El Hamam': 'الحمام',
      'El Alamein': 'العلمين',
      'Marina': 'مارينا',
      'Sidi Abdel Rahman': 'سيدي عبد الرحمن',
      'El Dabaa': 'الضبعة',
      'Mersa Matruh': 'مرسى مطروح',
      'Siwa': 'سيوة',
      'Bahariya': 'البحرية',
      'Farafra': 'الفرافرة',
      'Dakhla': 'الداخلة',
      'Kharga': 'الخارجة',
    };

    final Map<String, String> governorates = {
      'Cairo Governorate': 'محافظة القاهرة',
      'Alexandria Governorate': 'محافظة الإسكندرية',
      'Giza Governorate': 'محافظة الجيزة',
      'Beheira Governorate': 'محافظة البحيرة',
      'Port Said Governorate': 'محافظة بورسعيد',
      'Suez Governorate': 'محافظة السويس',
      'Luxor Governorate': 'محافظة الأقصر',
      'Dakahlia Governorate': 'محافظة الدقهلية',
      'Gharbia Governorate': 'محافظة الغربية',
      'Asyut Governorate': 'محافظة أسيوط',
      'Ismailia Governorate': 'محافظة الإسماعيلية',
      'Fayyum Governorate': 'محافظة الفيوم',
      'Sharqia Governorate': 'محافظة الشرقية',
      'Aswan Governorate': 'محافظة أسوان',
      'Damietta Governorate': 'محافظة دمياط',
      'Minya Governorate': 'محافظة المنيا',
      'Beni Suef Governorate': 'محافظة بني سويف',
      'Sohag Governorate': 'محافظة سوهاج',
      'Red Sea Governorate': 'محافظة البحر الأحمر',
      'New Valley Governorate': 'محافظة الوادي الجديد',
      'Matrouh Governorate': 'محافظة مطروح',
      'North Sinai Governorate': 'محافظة شمال سيناء',
      'South Sinai Governorate': 'محافظة جنوب سيناء',
      'Kafr El Sheikh Governorate': 'محافظة كفر الشيخ',
      'Qalyubia Governorate': 'محافظة القليوبية',
      'Monufia Governorate': 'محافظة المنوفية',
      'Qena Governorate': 'محافظة قنا',
      'Beheira': 'محافظة البحيرة',
      'Cairo': 'محافظة القاهرة',
      'Alexandria': 'محافظة الإسكندرية',
      'Giza': 'محافظة الجيزة',
      'Port Said': 'محافظة بورسعيد',
      'Suez': 'محافظة السويس',
      'Luxor': 'محافظة الأقصر',
      'Dakahlia': 'محافظة الدقهلية',
      'Gharbia': 'محافظة الغربية',
      'Asyut': 'محافظة أسيوط',
      'Ismailia': 'محافظة الإسماعيلية',
      'Fayyum': 'محافظة الفيوم',
      'Sharqia': 'محافظة الشرقية',
      'Aswan': 'محافظة أسوان',
      'Damietta': 'محافظة دمياط',
      'Minya': 'محافظة المنيا',
      'Beni Suef': 'محافظة بني سويف',
      'Sohag': 'محافظة سوهاج',
      'Red Sea': 'محافظة البحر الأحمر',
      'New Valley': 'محافظة الوادي الجديد',
      'Matrouh': 'محافظة مطروح',
      'North Sinai': 'محافظة شمال سيناء',
      'South Sinai': 'محافظة جنوب سيناء',
      'Kafr El Sheikh': 'محافظة كفر الشيخ',
      'Qalyubia': 'محافظة القليوبية',
      'Monufia': 'محافظة المنوفية',
      'Qena': 'محافظة قنا',
    };

    // First try to find an exact match
    if (cities.containsKey(location)) {
      String cityName = cities[location]!;
      // Try to find the governorate
      for (var entry in governorates.entries) {
        if (location.toLowerCase().contains(entry.key.toLowerCase())) {
          return '$cityName - ${entry.value}';
        }
      }
      return cityName;
    }

    // If no exact match, try partial matches
    for (var entry in cities.entries) {
      if (location.toLowerCase().contains(entry.key.toLowerCase())) {
        String cityName = entry.value;
        // Try to find the governorate
        for (var govEntry in governorates.entries) {
          if (location.toLowerCase().contains(govEntry.key.toLowerCase())) {
            return '$cityName - ${govEntry.value}';
          }
        }
        return cityName;
      }
    }

    // Check if the location is a governorate
    if (governorates.containsKey(location)) {
      return governorates[location]!;
    }

    // If no match found, return the original location
    return location;
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
          : AppColors.primaryColor.withOpacity(0.15)
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
