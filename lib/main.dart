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
import 'package:serat/Business_Logic/Cubit/qibla_cubit.dart';
import 'package:serat/Business_Logic/Cubit/quran_video_cubit.dart';
import 'package:serat/Data/Web_Services/quran_video_web_services.dart';
import 'package:serat/Presentation/screens/splash_screen.dart';
import 'package:serat/imports.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:serat/features/quran/routes/quran_routes.dart';
import 'package:serat/Business_Logic/Cubit/theme_cubit.dart';
import 'package:serat/shared/services/notification_service.dart';
import 'package:serat/core/theme/app_theme.dart';
import 'package:upgrader/upgrader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:serat/services/firebase_messaging_service.dart';
import 'package:quran_library/quran_library.dart';
import 'package:serat/core/services/home_widget_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await CacheHelper.init();
    await HomeWidgetService.updatePrayerWidget();
    return Future.value(true);
  });
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
bool isLight = false;
TimeOfDay? selectedTimeMorning;
TimeOfDay? selectedTimeEvening;
String? selectedMorning;
String? selectedEvening;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheHelper.init();
  await initializeAppSettings();

  // Initialize permission handler with error handling
  try {
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      final result = await Permission.notification.request();
      if (result.isDenied) {
        debugPrint('Notification permission denied');
      }
    }

    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();
        if (result.isDenied) {
          debugPrint('Exact alarm permission denied');
        }
      }
    }
  } catch (e) {
    debugPrint('Error requesting permissions: $e');
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize Firebase Messaging
  await FirebaseMessagingService().initNotifications();

  // Initialize Quran Library for KFGQPC fonts
  await QuranLibrary.init();

  Bloc.observer = MyGlobalObserver();
  HomeWidgetService.updatePrayerWidget(); // Initial update

  // Initialize Workmanager for background updates
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    "prayer_widget_sync",
    "prayer_widget_update_task",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    initialDelay: const Duration(minutes: 5),
  );

  runApp(SeratApp(isLight: isLight));

  // Update home widget every minute when the app is open
  Timer.periodic(const Duration(minutes: 1), (timer) {
    HomeWidgetService.updatePrayerWidget();
  });
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

class ArabicUpgraderMessages extends UpgraderMessages {
  ArabicUpgraderMessages() : super(code: 'ar');

  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'يتوفر إصدار جديد من هذا التطبيق!';
      case UpgraderMessage.buttonTitleIgnore:
        return 'تجاهل';
      case UpgraderMessage.buttonTitleLater:
        return 'لاحقًا';
      case UpgraderMessage.buttonTitleUpdate:
        return 'تحديث الآن';
      case UpgraderMessage.prompt:
        return 'هل ترغب في التحديث؟';
      case UpgraderMessage.releaseNotes:
        return 'ملاحظات الإصدار';
      case UpgraderMessage.title:
        return 'تحديث التطبيق';
      default:
        return super.message(messageKey) ?? '';
    }
  }
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
        BlocProvider(create: (context) => DownloadCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        child: BlocBuilder<ThemeCubit, ThemeState>(
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
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeCubit.get(context).isLightMode
                  ? ThemeMode.light
                  : ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              home: UpgradeAlert(
                upgrader: Upgrader(
                  languageCode: 'ar',
                  messages: ArabicUpgraderMessages(),
                ),
                child: SplashScreen(),
              ),
              routes: {
                ...QuranRoutes.getRoutes(),
              },
            );
          },
        ),
      ),
    );
  }
}
