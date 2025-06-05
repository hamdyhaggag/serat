import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Business_Logic/Cubit/theme_cubit.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/constants/prayer_times_constants.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/location.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/prayer_time.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/services/prayer_times_service.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/widgets/prayer_time_list.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Config/constants/app_text.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:serat/Presentation/Widgets/Shared/loading_indicator.dart';
import 'package:serat/Presentation/Widgets/Shared/error_view.dart';
import 'package:serat/shared/services/notification_service.dart';

/// The main screen for displaying prayer times.
class PrayerTimesScreen extends StatefulWidget {
  /// Creates a new [PrayerTimesScreen] instance.
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  bool _isLoading = true;
  String? _error;
  List<PrayerTime> _prayerTimes = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PrayerTimesService _prayerTimesService;

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
    _prayerTimesService = PrayerTimesService(
      dio: Dio(),
      notificationService: NotificationService(),
    );
  }

  Future<void> _loadPrayerTimes() async {
    final locationCubit = context.read<LocationCubit>();
    if (locationCubit.position != null) {
      final location = Location(
        latitude: locationCubit.position!.latitude,
        longitude: locationCubit.position!.longitude,
        name: locationCubit.locality ??
            locationCubit.administrativeArea ??
            locationCubit.country ??
            '',
      );
      await _fetchPrayerTimes(location);
    } else {
      setState(() {
        _isLoading = false;
        _error =
            locationCubit.errorMessage ?? PrayerTimesConstants.locationError;
      });
    }
  }

  Future<void> _fetchPrayerTimes(Location location) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        location: location,
        date: DateTime.now(),
      );

      final nextPrayer = _prayerTimesService.getNextPrayerTime(prayerTimes);
      _nextPrayerName = PrayerTimesConstants.prayerNames[nextPrayer.$1] ?? '';
      _timeUntilNextPrayer =
          _prayerTimesService.getTimeUntilNextPrayer(nextPrayer.$2);

      setState(() {
        _prayerTimes = prayerTimes.entries.map((entry) {
          return PrayerTime(
            name: PrayerTimesConstants.prayerNames[entry.key] ?? '',
            time: entry.value,
            icon: PrayerTimesConstants.prayerIcons[entry.key] ??
                Icons.access_time,
            isNext: entry.key == nextPrayer.$1,
          );
        }).toList();
        _isLoading = false;
      });

      await _prayerTimesService.schedulePrayerNotifications(prayerTimes);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
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
      appBar: const CustomAppBar(title: 'مواقيت الصلاة'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const LoadingIndicator()
            : _error != null
                ? ErrorView(
                    message: _error!,
                    onRetry: _loadPrayerTimes,
                  )
                : SingleChildScrollView(
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
                                  fontSize:
                                      PrayerTimesConstants.countdownFontSize,
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
                  ),
      ),
    );
  }
}
