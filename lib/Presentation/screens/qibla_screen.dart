import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/imports.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  QiblaScreenState createState() => QiblaScreenState();
}

class QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    _getQiblaDirection();
  }

  Future<void> _getQiblaDirection() async {
    final locationCubit = LocationCubit.get(context);
    if (locationCubit.position != null) {
      await QiblaCubit.get(context).getQiblaDirection(
        latitude: locationCubit.position!.latitude,
        longitude: locationCubit.position!.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'القبلة', isHome: true),
      body: BlocConsumer<QiblaCubit, QiblaState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (QiblaCubit.get(context).directionModel == null) {
            return RefreshIndicator(
              onRefresh: () async {
                final locationCubit = LocationCubit.get(context);
                await locationCubit.getMyCurrentLocation();
                if (locationCubit.position != null && mounted) {
                  await QiblaCubit.get(context).getQiblaDirection(
                    latitude: locationCubit.position!.latitude,
                    longitude: locationCubit.position!.longitude,
                  );
                }
              },
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (QiblaCubit.get(context).directionModel == null)
                            Image.asset(
                              'assets/error404.png',
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.6,
                            ),
                          AppText(
                            "تأكد من الاتصال بالإنترنت \n و تفعيل الموقع",
                            align: TextAlign.center,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Builder(
              builder: (context) {
                return Column(
                  children: <Widget>[Expanded(child: _buildCompass())],
                );
              },
            );
          }
        },
      ),
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
              return Text('Error reading heading: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                child: AppText(
                  "الجهاز لا يدعم السينسور المستخدم لتحديد الاتجاه",
                ),
              );
            }
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEBEBEB),
                  ),
                  child: Transform.rotate(
                    angle: rotatedAngle ?? 0,
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/qibla_screen_dark.png'
                          : 'assets/qibla_screen.png',
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        '${direction.round()}°',
                        color: AppColors.primaryColor,
                        fontSize: 50,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: (width / 2) - ((width / 4) / 2),
                  top: (height - width) / 10,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (direction < qibla!)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  'تحرك إلى اليمين',
                                  fontSize: 15,
                                  fontFamily: 'DIN',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? const Color(0xff0c8ee1)
                                          : AppColors.primaryColor,
                                ),
                                SizedBox(width: 5.w),
                                Icon(
                                  FontAwesomeIcons.arrowRightLong,
                                  color:
                                      isDarkMode
                                          ? const Color(0xff0c8ee1)
                                          : AppColors.primaryColor,
                                  size: 40,
                                ),
                              ],
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (direction > qibla)
                            Row(
                              children: [
                                AppText(
                                  'تحرك إلى اليسار',
                                  fontSize: 15,
                                  fontFamily: 'DIN',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? const Color(0xff0c8ee1)
                                          : AppColors.primaryColor,
                                ),
                                SizedBox(width: 5.w),
                                Icon(
                                  FontAwesomeIcons.arrowLeftLong,
                                  color:
                                      isDarkMode
                                          ? const Color(0xff0c8ee1)
                                          : AppColors.primaryColor,
                                  size: 40,
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(
                        height: qibla == direction ? 100 : 0,
                        width: qibla == direction ? 100 : 0,
                        child: Image.asset('assets/qibla_icon.png'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.18,
                  top: MediaQuery.of(context).size.height * 0.68,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        'اتجاة القبلة هو  $qibla° من الشمال ',
                        color:
                            isDarkMode
                                ? const Color(0xff0c8ee1)
                                : AppColors.primaryColor,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
