import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/services/adhan_service.dart';

class AdhanCubit extends Cubit<AdhanState> {
  AdhanCubit() : super(AdhanInitial());

  static AdhanCubit get(context) => BlocProvider.of(context);

  bool isAdhanEnabled = true;
  bool isPreAdhanEnabled = false;
  int preAdhanMinutes = 15;

  Map<String, bool> prayerAdhanEnabled = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  bool isPlayingPreview = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isAdhanEnabled = prefs.getBool('isAdhanEnabled') ?? true;
    isPreAdhanEnabled = prefs.getBool('isPreAdhanEnabled') ?? false;
    preAdhanMinutes = prefs.getInt('preAdhanMinutes') ?? 15;

    prayerAdhanEnabled['Fajr'] = prefs.getBool('adhan_Fajr') ?? true;
    prayerAdhanEnabled['Dhuhr'] = prefs.getBool('adhan_Dhuhr') ?? true;
    prayerAdhanEnabled['Asr'] = prefs.getBool('adhan_Asr') ?? true;
    prayerAdhanEnabled['Maghrib'] = prefs.getBool('adhan_Maghrib') ?? true;
    prayerAdhanEnabled['Isha'] = prefs.getBool('adhan_Isha') ?? true;

    // Setup listener so UI knows when adhan stops from notification
    AdhanService.initializeIsolateListener();

    // UI Port to sync state
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping('adhan_ui_port');
    IsolateNameServer.registerPortWithName(port.sendPort, 'adhan_ui_port');
    port.listen((message) {
      if (message == "stop_now") {
        isPlayingPreview = false;
        emit(AdhanPreviewStopped());
      }
    });

    emit(AdhanSettingsLoaded());
  }

  void toggleGlobalAdhan(bool value) async {
    isAdhanEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdhanEnabled', value);
    await AdhanService.scheduleAdhans();
    emit(AdhanSettingsChanged());
  }

  void togglePrayerAdhan(String prayer, bool value) async {
    prayerAdhanEnabled[prayer] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_$prayer', value);
    await AdhanService.scheduleAdhans();
    emit(AdhanSettingsChanged());
  }

  void togglePreAdhan(bool value) async {
    isPreAdhanEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPreAdhanEnabled', value);
    await AdhanService.scheduleAdhans();
    emit(AdhanSettingsChanged());
  }

  void updatePreAdhanMinutes(int value) async {
    preAdhanMinutes = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preAdhanMinutes', value);
    await AdhanService.scheduleAdhans();
    emit(AdhanSettingsChanged());
  }

  void playPreview() async {
    if (isPlayingPreview) {
      AdhanService.sendStopSignal();
      isPlayingPreview = false;
      emit(AdhanPreviewStopped());
    } else {
      isPlayingPreview = true;
      emit(AdhanPreviewPlaying());
      try {
        await AdhanService.player
            .play(AssetSource('adhan/adhan -mishary rashid.mp3'));
        AdhanService.player.onPlayerComplete.listen((event) {
          isPlayingPreview = false;
          emit(AdhanPreviewStopped());
        });
      } catch (e) {
        isPlayingPreview = false;
        emit(AdhanPreviewStopped());
      }
    }
  }

  void testFullAdhan() async {
    await AdhanService.testFullExperience();
    isPlayingPreview = true;
    emit(AdhanPreviewPlaying());
  }

  void testPreAdhan() async {
    await AdhanService.testPreAdhanExperience();
    isPlayingPreview = true;
    emit(AdhanPreviewPlaying());
  }

  void stopAdhan() {
    AdhanService.sendStopSignal();
    isPlayingPreview = false;
    emit(AdhanPreviewStopped());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

abstract class AdhanState {}

class AdhanInitial extends AdhanState {}

class AdhanSettingsLoaded extends AdhanState {}

class AdhanSettingsChanged extends AdhanState {}

class AdhanPreviewPlaying extends AdhanState {}

class AdhanPreviewStopped extends AdhanState {}
