import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/constants/prayer_times_constants.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/location.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/prayer_time.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/weekly_prayer_times.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/services/enhanced_prayer_times_service.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/widgets/prayer_time_list.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/widgets/weekly_prayer_times_widget.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:serat/Presentation/Widgets/Shared/loading_indicator.dart';
import 'package:serat/Presentation/Widgets/Shared/error_view.dart';
import 'package:serat/shared/services/notification_service.dart';

/// Enhanced prayer times screen with offline support and weekly view.
class EnhancedPrayerTimesScreen extends StatefulWidget {
  /// Creates a new [EnhancedPrayerTimesScreen] instance.
  const EnhancedPrayerTimesScreen({super.key});

  @override
  State<EnhancedPrayerTimesScreen> createState() =>
      _EnhancedPrayerTimesScreenState();
}

class _EnhancedPrayerTimesScreenState extends State<EnhancedPrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  bool _isLoading = true;
  String? _error;
  List<PrayerTime> _prayerTimes = [];
  WeeklyPrayerTimes? _weeklyData;
  bool _showWeeklyView = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late EnhancedPrayerTimesService _prayerTimesService;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeServices();
    _startCountdownTimer();
    _loadPrayerTimes();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: PrayerTimesConstants.fadeAnimationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _initializeServices() {
    _prayerTimesService = EnhancedPrayerTimesService(
      dio: Dio(),
      notificationService: NotificationService(),
    );
  }

  Future<void> _loadPrayerTimes() async {
    try {
      await _prayerTimesService.init();

      // First try to get cached location
      Location? cachedLocation = await _prayerTimesService.getCachedLocation();

      // Get location from cubit or use cached location
      final locationCubit = context.read<LocationCubit>();
      Location? location;

      if (locationCubit.position != null) {
        location = Location(
          latitude: locationCubit.position!.latitude,
          longitude: locationCubit.position!.longitude,
          name: locationCubit.locality ??
              locationCubit.administrativeArea ??
              locationCubit.country ??
              '',
        );
      } else if (cachedLocation != null) {
        location = cachedLocation;
        _isFromCache = true;
      } else {
        setState(() {
          _isLoading = false;
          _error =
              locationCubit.errorMessage ?? PrayerTimesConstants.locationError;
        });
        return;
      }

      await _fetchPrayerTimes(location);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchPrayerTimes(Location location) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Check if we have valid cached data first
      final hasValidCache = await _prayerTimesService.hasValidCache();
      if (hasValidCache) {
        final cachedTimes =
            await _prayerTimesService.getTodayPrayerTimes(location: location);
        if (cachedTimes != null) {
          _updateUIWithPrayerTimes(cachedTimes, true);
          return;
        }
      }

      // Fetch fresh data
      final prayerTimes = await _prayerTimesService.getTodayPrayerTimes(
        location: location,
        forceRefresh: true,
      );

      _updateUIWithPrayerTimes(prayerTimes, false);

      // Schedule notifications
      await _prayerTimesService.schedulePrayerNotifications(prayerTimes);
    } catch (e) {
      // If fresh data fails, try to get any cached data
      final cachedTimes =
          await _prayerTimesService.getTodayPrayerTimes(location: location);
      if (cachedTimes != null) {
        _updateUIWithPrayerTimes(cachedTimes, true);
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _updateUIWithPrayerTimes(
      Map<String, String> prayerTimes, bool fromCache) {
    final nextPrayer = _prayerTimesService.getNextPrayerTime(prayerTimes);
    _nextPrayerName = PrayerTimesConstants.prayerNames[nextPrayer.$1] ?? '';
    _timeUntilNextPrayer =
        _prayerTimesService.getTimeUntilNextPrayer(nextPrayer.$2);

    setState(() {
      _prayerTimes = prayerTimes.entries.map((entry) {
        return PrayerTime(
          name: PrayerTimesConstants.prayerNames[entry.key] ?? '',
          time: entry.value,
          icon:
              PrayerTimesConstants.prayerIcons[entry.key] ?? Icons.access_time,
          isNext: entry.key == nextPrayer.$1,
        );
      }).toList();
      _isLoading = false;
      _isFromCache = fromCache;
    });
  }

  Future<void> _loadWeeklyData() async {
    try {
      final locationCubit = context.read<LocationCubit>();
      if (locationCubit.position == null) return;

      final location = Location(
        latitude: locationCubit.position!.latitude,
        longitude: locationCubit.position!.longitude,
        name: locationCubit.locality ??
            locationCubit.administrativeArea ??
            locationCubit.country ??
            '',
      );

      // Check if we have cached weekly data
      final hasCurrentWeekCache =
          await _prayerTimesService.isCurrentWeekCached();
      if (!hasCurrentWeekCache) {
        // Fetch weekly data
        await _prayerTimesService.getTodayPrayerTimes(
          location: location,
          forceRefresh: true,
        );
      }

      // Get cached weekly data using the service method
      final weeklyData = await _prayerTimesService.getCachedWeeklyPrayerTimes();
      if (weeklyData != null) {
        setState(() {
          _weeklyData = weeklyData;
        });
      }
    } catch (e) {
      print('Error loading weekly data: $e');
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      PrayerTimesConstants.countdownUpdateInterval,
      (timer) {
        if (mounted) {
          setState(() {
            _timeUntilNextPrayer =
                _timeUntilNextPrayer - const Duration(seconds: 1);
            if (_timeUntilNextPrayer.isNegative) {
              _loadPrayerTimes();
            }
          });
        }
      },
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _toggleWeeklyView() {
    setState(() {
      _showWeeklyView = !_showWeeklyView;
    });

    if (_showWeeklyView && _weeklyData == null) {
      _loadWeeklyData();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: CustomAppBar(
        title: 'مواقيت الصلاة',
        actions: [
          IconButton(
            icon: Icon(
              _showWeeklyView ? Icons.view_day : Icons.view_week,
              color: Colors.white,
            ),
            onPressed: _toggleWeeklyView,
          ),
          if (_isFromCache)
            IconButton(
              icon: const Icon(
                Icons.cloud_off,
                color: Colors.orange,
              ),
              onPressed: () => _loadPrayerTimes(),
              tooltip: 'بيانات مخزنة مؤقتاً',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const LoadingIndicator()
            : _error != null
                ? ErrorView(
                    message: _error!,
                    onRetry: _loadPrayerTimes,
                  )
                : _showWeeklyView && _weeklyData != null
                    ? _buildWeeklyView(isDarkMode)
                    : _buildDailyView(isDarkMode),
      ),
    );
  }

  Widget _buildDailyView(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'متبقي حتى $_nextPrayerName',
                  style: TextStyle(
                    fontSize: PrayerTimesConstants.countdownFontSize,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCountdown(_timeUntilNextPrayer),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrayerTimeList(
            prayerTimes: _prayerTimes,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          WeeklyPrayerTimesWidget(
            weeklyData: _weeklyData!,
            isDarkMode: isDarkMode,
            onDaySelected: (date) {
              // Handle day selection - could show detailed view for that day
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم اختيار ${date.toIso8601String()}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
