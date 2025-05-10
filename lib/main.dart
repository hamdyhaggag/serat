import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Business_Logic/Cubit/settings_cubit.dart';
import 'package:serat/Business_Logic/Cubit/counter_cubit.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart';
import 'package:serat/Business_Logic/Cubit/app_cubit.dart';
import 'package:serat/Business_Logic/Cubit/app_states.dart';
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Presentation/screens/splash_screen.dart';
import 'package:serat/imports.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(message.messageId);
  }
}

TimeOfDay? stringToTimeOfDay(String timeString) {
  if (timeString.isNotEmpty) {
    final parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  return null;
}

bool isEnterBefore = false;
int radioValue = 5;
bool isLight = CacheHelper.getBoolean(key: 'isLight');
TimeOfDay? selectedTimeMorning;
TimeOfDay? selectedTimeEvening;
String? selectedMorning;
String? selectedEvening;

final lightThemeData = ThemeData(
  primaryColor: Colors.blue,
  textTheme: const TextTheme(labelLarge: TextStyle(color: Colors.white70)),
  brightness: Brightness.light,
  hintColor: Colors.blue,
);

final darkThemeData = ThemeData(
  primaryColor: Colors.blue,
  textTheme: const TextTheme(labelLarge: TextStyle(color: Color(0xff1F1F1F))),
  brightness: Brightness.dark,
  hintColor: Colors.blue,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initializeNotification();

  await CacheHelper.init();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initializeAppSettings();

  Bloc.observer = MyGlobalObserver();

  runApp(EasyDynamicThemeWidget(child: SeratApp(isLight: isLight)));
}

Future<void> initializeAppSettings() async {
  radioValue = CacheHelper.getInteger(key: 'value');
  isEnterBefore = CacheHelper.getBoolean(key: 'isEnterBefore');
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
          create: (context) => LocationCubit()..getMyCurrentLocation(),
        ),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => CounterCubit()),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => QiblaCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: "tatmaen - تَطْمَئِن",
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
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
