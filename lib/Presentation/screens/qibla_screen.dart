import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Presentation/widgets/error_widget.dart';
import 'package:serat/imports.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  QiblaScreenState createState() => QiblaScreenState();
}

class QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQibla();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    final locationCubit = LocationCubit.get(context);
    if (locationCubit.position == null) {
      await locationCubit.getMyCurrentLocation();
    }
    if (locationCubit.position != null && mounted) {
      await QiblaCubit.get(context).getQiblaDirection(
        latitude: locationCubit.position!.latitude,
        longitude: locationCubit.position!.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<QiblaCubit, QiblaState>(
      listener: (context, state) {
        if (state is GetQiblaDirectionError) {
          final locationCubit = LocationCubit.get(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locationCubit.errorMessage ??
                  'حدث خطأ في تحديد اتجاه القبلة'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final locationCubit = LocationCubit.get(context);
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'القبلة',
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
            ),
            centerTitle: true,
          ),
          body: state is GetQiblaDirectionLoading
              ? const Center(child: CircularProgressIndicator())
              : state is GetQiblaDirectionError
                  ? AppErrorWidget(
                      message: locationCubit.errorMessage ??
                          'حدث خطأ في تحديد اتجاه القبلة\nيرجى المحاولة مرة أخرى',
                      icon: Icons.location_off_rounded,
                      isDarkMode: isDarkMode,
                      onRetry: () async {
                        await locationCubit.getMyCurrentLocation();
                        if (locationCubit.position != null && mounted) {
                          await QiblaCubit.get(context).getQiblaDirection(
                            latitude: locationCubit.position!.latitude,
                            longitude: locationCubit.position!.longitude,
                          );
                        }
                      },
                    )
                  : QiblaCubit.get(context).directionModel == null
                      ? AppErrorWidget(
                          message: locationCubit.errorMessage ??
                              'تأكد من الاتصال بالإنترنت\nوتفعيل الموقع',
                          icon: Icons.location_off_rounded,
                          isDarkMode: isDarkMode,
                          onRetry: () async {
                            await locationCubit.getMyCurrentLocation();
                            if (locationCubit.position != null && mounted) {
                              await QiblaCubit.get(context).getQiblaDirection(
                                latitude: locationCubit.position!.latitude,
                                longitude: locationCubit.position!.longitude,
                              );
                            }
                          },
                        )
                      : Builder(
                          builder: (context) {
                            return Column(
                              children: <Widget>[
                                Expanded(child: _buildCompass())
                              ],
                            );
                          },
                        ),
        );
      },
    );
  }

  Widget _buildCompass() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return BlocConsumer<QiblaCubit, QiblaState>(
      listener: (context, state) {},
      builder: (context, state) {
        int? qibla;
        if (QiblaCubit.get(context).directionModel != null) {
          qibla =
              QiblaCubit.get(context).directionModel!.data.direction.round();
        }

        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compass_calibration_rounded,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      "الجهاز لا يدعم السينسور المستخدم لتحديد الاتجاه",
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 3,
                ),
              );
            }

            double? direction = snapshot.data?.heading;
            double? rotatedAngle;

            if (direction != null) {
              direction = direction.round().toDouble();
              if (direction < 0) {
                direction = direction + 360;
              }
              if (qibla == direction) {
                Vibration.vibrate();
              }
              double rotationSpeedFactor = 0.2;
              rotatedAngle =
                  (direction * (math.pi / 180) * -1) * rotationSpeedFactor;
            }

            if (direction == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compass_calibration_rounded,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      "الجهاز لا يدعم السينسور المستخدم لتحديد الاتجاه",
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                Center(
                  child: Container(
                    width: width * 0.8,
                    height: width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Qibla Indicator
                        if (qibla != null)
                          Positioned(
                            left: width * 0.4,
                            top: width * 0.4,
                            child: Transform.rotate(
                              angle: (qibla * (math.pi / 180)) -
                                  (rotatedAngle ?? 0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 4,
                                    height: width * 0.35,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          '${direction.round()}°',
                          color: AppColors.primaryColor,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: (height - width) / 10,
                  child: Center(
                    child: Column(
                      children: [
                        if (direction < qibla!)
                          _buildDirectionIndicator(
                            'تحرك إلى اليمين',
                            Icons.arrow_back_rounded,
                          ),
                        if (direction > qibla)
                          _buildDirectionIndicator(
                            'تحرك إلى اليسار',
                            Icons.arrow_forward_rounded,
                          ),
                        if (qibla == direction)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        'اتجاة القبلة هو  $qibla° من الشمال ',
                        color: AppColors.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDirectionIndicator(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.primaryColor, size: 24),
        ],
      ),
    );
  }
}
