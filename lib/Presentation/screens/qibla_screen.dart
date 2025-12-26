import 'dart:math' as math;
import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Presentation/widgets/error_widget.dart';
import 'package:serat/imports.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  QiblaScreenState createState() => QiblaScreenState();
}

class QiblaScreenState extends State<QiblaScreen> {
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _initializeQibla();
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

    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) {
        final locationCubit = LocationCubit.get(context);
        final qiblaCubit = QiblaCubit.get(context);
        final qiblaDirection = qiblaCubit.directionModel?.data.direction;

        if (state is GetQiblaDirectionLoading) {
          return Scaffold(
            backgroundColor:
                isDarkMode ? const Color(0xff121212) : Colors.white,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GetQiblaDirectionError || qiblaDirection == null) {
          return Scaffold(
            backgroundColor:
                isDarkMode ? const Color(0xff121212) : Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            body: AppErrorWidget(
              message: locationCubit.errorMessage ??
                  'تأكد من تفعيل الموقع والإنترنت لتحديد القبلة',
              icon: Icons.location_off_rounded,
              isDarkMode: isDarkMode,
              onRetry: _initializeQibla,
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor:
              isDarkMode ? const Color(0xff121212) : const Color(0xffF5F5F7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "القبلة",
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background Gradient
              if (isDarkMode)
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.15),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: qiblaCubit.isFromCache
                              ? Colors.orange.withOpacity(0.1)
                              : AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: qiblaCubit.isFromCache
                                ? Colors.orange.withOpacity(0.3)
                                : AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              qiblaCubit.isFromCache
                                  ? Icons.wifi_off_rounded
                                  : Icons.location_on_rounded,
                              size: 16,
                              color: qiblaCubit.isFromCache
                                  ? Colors.orange
                                  : AppColors.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              qiblaCubit.isFromCache
                                  ? 'وضع غير متصل'
                                  : 'موقع دقيق',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: qiblaCubit.isFromCache
                                    ? Colors.orange
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade().slideY(begin: -0.5, end: 0),

                      const SizedBox(height: 40),

                      // Compass Widget
                      StreamBuilder<CompassEvent>(
                        stream: FlutterCompass.events,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "خطأ في البوصلة",
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final direction = snapshot.data?.heading ?? 0;
                          final qiblaDir = qiblaDirection.toDouble();

                          // Calculate deviation for feedback
                          final deviation = (direction - qiblaDir).abs() % 360;
                          bool isAligned = deviation < 2 || deviation > 358;

                          if (isAligned && !_hasVibrated) {
                            HapticFeedback.heavyImpact();
                            _hasVibrated = true;
                          } else if (!isAligned) {
                            _hasVibrated = false;
                          }

                          return _buildModernCompass(
                            context,
                            direction,
                            qiblaDir,
                            isAligned,
                            isDarkMode,
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Footer Info
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: "${qiblaDirection.round()}",
                                  ),
                                  TextSpan(
                                    text: "°",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "درجة من الشمال",
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade().slideY(begin: 0.5, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernCompass(BuildContext context, double heading,
      double qiblaDir, bool isAligned, bool isDarkMode) {
    final size = MediaQuery.of(context).size.width * 0.82;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isAligned
                  ? Colors.green.withOpacity(0.2)
                  : Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring with Gradient
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isAligned
                      ? [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05)
                        ]
                      : [
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.02),
                        ],
                ),
                border: Border.all(
                  color: isAligned
                      ? Colors.green.withOpacity(0.5)
                      : isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                  width: 2,
                ),
              ),
            ),

            // Degree Ticks Background (Static)
            ...List.generate(72, (index) {
              final angle = (index * 5) * (math.pi / 180);
              return Transform.rotate(
                angle: angle,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: index % 18 == 0 ? 15 : 8,
                    width: index % 18 == 0 ? 3 : 1,
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      color: index % 18 == 0
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.white38 : Colors.black38),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            }),

            // Rotating Compass Dial
            Transform.rotate(
              angle: -heading * (math.pi / 180),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cardinal Directions (N, E, S, W)
                  _buildCardinalDirection('N', 0, isDarkMode),
                  _buildCardinalDirection('E', 90, isDarkMode),
                  _buildCardinalDirection('S', 180, isDarkMode),
                  _buildCardinalDirection('W', 270, isDarkMode),

                  // Degree Numbers (30, 60, ... 330)
                  ...List.generate(12, (index) {
                    final degree = index * 30;
                    if (degree % 90 == 0) return const SizedBox.shrink();
                    return _buildDegreeNumber(
                        degree.toString(), degree.toDouble(), isDarkMode);
                  }),

                  // Kaaba Icon Pointer
                  Transform.rotate(
                    angle: qiblaDir * (math.pi / 180),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(height: 55), // Offset from edge
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              'assets/icon/qibla.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ).animate(target: isAligned ? 1 : 0).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.2, 1.2)),

                          // Guide Line to Center
                          Container(
                            height: (size / 2) - 130,
                            width: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Pin
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),

            // Alignment Success Indicator (Overlay)
            if (isAligned)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: Icon(Icons.check_rounded, color: Colors.green, size: 50)
                    .animate()
                    .fadeIn()
                    .scale(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardinalDirection(
      String text, double angleDeg, bool isDarkMode) {
    return Transform.rotate(
      angle: angleDeg * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 35),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: text == 'N'
                  ? Colors.red
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDegreeNumber(String text, double angleDeg, bool isDarkMode) {
    return Transform.rotate(
      angle: angleDeg * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 35),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white38 : Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}
