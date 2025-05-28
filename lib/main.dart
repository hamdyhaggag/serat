import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart' as location;
import 'package:serat/Business_Logic/Cubit/settings_cubit.dart';
import 'package:serat/Business_Logic/Cubit/counter_cubit.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart' as navigation;
import 'package:serat/Business_Logic/Cubit/app_cubit.dart';
import 'package:serat/Business_Logic/Cubit/app_states.dart';
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Business_Logic/Cubit/quran_video_cubit.dart';
import 'package:serat/Data/Web_Services/quran_video_web_services.dart';
import 'package:serat/Presentation/screens/splash_screen.dart';
import 'package:serat/imports.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:serat/features/quran/routes/quran_routes.dart';
import 'package:serat/Business_Logic/Cubit/theme_cubit.dart';

TimeOfDay? stringToTimeOfDay(String timeString) {
  if (timeString.isNotEmpty) {
    final parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  return null;
}

bool isEnterBefore = false;
int radioValue = 5;
bool isLight = false;
TimeOfDay? selectedTimeMorning;
TimeOfDay? selectedTimeEvening;
String? selectedMorning;
String? selectedEvening;

final lightThemeData = ThemeData(
  primaryColor: AppColors.primaryColor,
  textTheme: const TextTheme(labelLarge: TextStyle(color: Colors.white70)),
  brightness: Brightness.light,
  hintColor: AppColors.primaryColor,
);

final darkThemeData = ThemeData(
  primaryColor: AppColors.primaryColor,
  textTheme: const TextTheme(labelLarge: TextStyle(color: Color(0xff1F1F1F))),
  brightness: Brightness.dark,
  hintColor: AppColors.primaryColor,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await initializeAppSettings();

  // Initialize permission handler with error handling
  try {
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }

    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  } catch (e) {
    debugPrint('Error requesting permissions: $e');
  }

  Bloc.observer = MyGlobalObserver();

  runApp(EasyDynamicThemeWidget(child: SeratApp(isLight: isLight)));
}

Future<void> initializeAppSettings() async {
  radioValue = CacheHelper.getInteger(key: 'value');
  isEnterBefore = CacheHelper.getBoolean(key: 'isEnterBefore');
  isLight = CacheHelper.getBoolean(key: 'isLight');
  selectedMorning = CacheHelper.getString(key: 'Morning');
  selectedEvening = CacheHelper.getString(key: 'Evening');
  selectedTimeMorning = stringToTimeOfDay(selectedMorning!);
  selectedTimeEvening = stringToTimeOfDay(selectedEvening!);

  log(selectedMorning ?? "No Morning Time");
  log(selectedEvening ?? "No Evening Time");

  DioHelper.init();
}

class SeratApp extends StatelessWidget {
  final bool? isLight;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const SeratApp({super.key, this.isLight});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider(
          create: (context) => location.LocationCubit()..getMyCurrentLocation(),
        ),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => CounterCubit()),
        BlocProvider(create: (context) => navigation.NavigationCubit()),
        BlocProvider(create: (context) => QiblaCubit()),
        BlocProvider(
          create: (context) => QuranVideoCubit(QuranVideoWebServices()),
        ),
        BlocProvider(create: (context) => RecitersCubit()),
        BlocProvider(create: (context) => QuranCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  title: "Serat - صراط",
                  locale: const Locale('ar', 'SA'),
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('ar', 'SA')],
                  theme: lightThemeData.copyWith(
                    textTheme: const TextTheme(
                      titleMedium: TextStyle(fontSize: 25, fontFamily: 'DIN'),
                      bodyMedium: TextStyle(fontSize: 30, fontFamily: 'DIN'),
                    ),
                  ),
                  darkTheme: darkThemeData.copyWith(
                    textTheme: const TextTheme(
                      titleMedium: TextStyle(
                        fontSize: 25,
                        fontFamily: 'DIN',
                        color: Colors.white,
                      ),
                      bodyMedium: TextStyle(
                        fontSize: 30,
                        fontFamily: 'DIN',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  themeMode: ThemeCubit.get(context).isLightMode
                      ? ThemeMode.light
                      : ThemeMode.dark,
                  debugShowCheckedModeBanner: false,
                  home: const SplashScreen(),
                  routes: {
                    ...QuranRoutes.getRoutes(),
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
