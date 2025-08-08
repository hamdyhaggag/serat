import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Data/services/download_service.dart';
import 'package:serat/services/reciter_notification_service.dart';

enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final DownloadService _downloadService = DownloadService();
  final ReciterNotificationService _notificationService =
      ReciterNotificationService();

  PlaybackState _playbackState = PlaybackState.stopped;
  String _currentReciterName = '';
  String _currentSurahName = '';
  int? _currentSurahNumber;
  Moshaf? _currentMoshaf;
  Reciter? _currentReciter;
  bool _autoPlayNextSura = false;
  bool _isInitialized = false;

  // Stream controllers for state updates
  final StreamController<PlaybackState> _playbackStateController =
      StreamController<PlaybackState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Getters
  PlaybackState get playbackState => _playbackState;
  String get currentReciterName => _currentReciterName;
  String get currentSurahName => _currentSurahName;
  int? get currentSurahNumber => _currentSurahNumber;
  bool get autoPlayNextSura => _autoPlayNextSura;
  bool get isInitialized => _isInitialized;

  // Streams
  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _downloadService.initialize();
      await _notificationService.initialize();
      _setupAudioListeners();
      await _audioPlayer.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      _errorController.add('Failed to initialize audio player: $e');
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _playbackState = PlaybackState.playing;
          break;
        case PlayerState.paused:
          _playbackState = PlaybackState.paused;
          break;
        case PlayerState.stopped:
          _playbackState = PlaybackState.stopped;
          break;
        case PlayerState.completed:
          _playbackState = PlaybackState.stopped;
          _handlePlaybackComplete();
          break;
        default:
          _playbackState = PlaybackState.stopped;
      }
      _playbackStateController.add(_playbackState);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });

    _audioPlayer.onLog.listen((message) {
      if (message.toLowerCase().contains('error')) {
        _errorController.add('Audio player error: $message');
      }
    });

    _notificationService.onStop = stop;
  }

  Future<void> playRecitation({
    required Reciter reciter,
    required Moshaf moshaf,
    required int surahNumber,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _playbackState = PlaybackState.loading;
      _playbackStateController.add(_playbackState);

      // Check if available offline first
      final offlinePath = await _downloadService.getOfflineAudioPath(
        reciter.id.toString(),
        moshaf.id.toString(),
        surahNumber,
      );

      String audioSource;
      if (offlinePath != null) {
        audioSource = offlinePath;
      } else {
        audioSource = _buildAudioUrl(moshaf.server, surahNumber);
      }

      // Stop current playback if any
      if (_playbackState == PlaybackState.playing) {
        await _audioPlayer.stop();
      }

      // Set new source and play
      await _audioPlayer.setSourceUrl(audioSource);
      await _audioPlayer.resume();

      // Update current state
      _currentReciter = reciter;
      _currentMoshaf = moshaf;
      _currentSurahNumber = surahNumber;
      _currentReciterName = reciter.name;
      _currentSurahName = _getSurahName(surahNumber);

      // Show notification
      await _notificationService.showReciterNotification(
        reciterName: _currentReciterName,
        surahName: _currentSurahName,
        isPlaying: true,
      );
    } catch (e) {
      _playbackState = PlaybackState.error;
      _playbackStateController.add(_playbackState);
      _errorController.add('Failed to play recitation: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      await _notificationService.showReciterNotification(
        reciterName: _currentReciterName,
        surahName: _currentSurahName,
        isPlaying: false,
      );
    } catch (e) {
      _errorController.add('Failed to pause: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      await _notificationService.showReciterNotification(
        reciterName: _currentReciterName,
        surahName: _currentSurahName,
        isPlaying: true,
      );
    } catch (e) {
      _errorController.add('Failed to resume: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _notificationService.removeNotification();

      _currentReciterName = '';
      _currentSurahName = '';
      _currentSurahNumber = null;
      _currentMoshaf = null;
      _currentReciter = null;
    } catch (e) {
      _errorController.add('Failed to stop: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _errorController.add('Failed to seek: $e');
    }
  }

  Future<void> seekForward(Duration duration) async {
    try {
      final currentPosition = await _audioPlayer.getCurrentPosition();
      final audioDuration = await _audioPlayer.getDuration();

      if (currentPosition != null && audioDuration != null) {
        final newPosition = currentPosition + duration;
        if (newPosition <= audioDuration) {
          await _audioPlayer.seek(newPosition);
        }
      }
    } catch (e) {
      _errorController.add('Failed to seek forward: $e');
    }
  }

  Future<void> seekBackward(Duration duration) async {
    try {
      final currentPosition = await _audioPlayer.getCurrentPosition();

      if (currentPosition != null) {
        final newPosition = currentPosition - duration;
        await _audioPlayer.seek(
          newPosition.inMilliseconds > 0 ? newPosition : Duration.zero,
        );
      }
    } catch (e) {
      _errorController.add('Failed to seek backward: $e');
    }
  }

  void setAutoPlayNextSura(bool value) {
    _autoPlayNextSura = value;
  }

  Future<void> _handlePlaybackComplete() async {
    if (!_autoPlayNextSura ||
        _currentSurahNumber == null ||
        _currentMoshaf == null ||
        _currentReciter == null) {
      return;
    }

    try {
      final surahList = _currentMoshaf!.surahList
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();

      final currentIndex = surahList.indexOf(_currentSurahNumber!);
      if (currentIndex != -1 && currentIndex + 1 < surahList.length) {
        final nextSurah = surahList[currentIndex + 1];
        await playRecitation(
          reciter: _currentReciter!,
          moshaf: _currentMoshaf!,
          surahNumber: nextSurah,
        );
      }
    } catch (e) {
      _errorController.add('Failed to auto-play next surah: $e');
    }
  }

  String _buildAudioUrl(String server, int surah) {
    String serverUrl = server;
    if (!serverUrl.endsWith('/')) serverUrl = '$serverUrl/';
    return '$serverUrl${surah.toString().padLeft(3, '0')}.mp3';
  }

  String _getSurahName(int surahNumber) {
    final surahs = {
      1: 'الفاتحة',
      2: 'البقرة',
      3: 'آل عمران',
      4: 'النساء',
      5: 'المائدة',
      6: 'الأنعام',
      7: 'الأعراف',
      8: 'الأنفال',
      9: 'التوبة',
      10: 'يونس',
      11: 'هود',
      12: 'يوسف',
      13: 'الرعد',
      14: 'إبراهيم',
      15: 'الحجر',
      16: 'النحل',
      17: 'الإسراء',
      18: 'الكهف',
      19: 'مريم',
      20: 'طه',
      21: 'الأنبياء',
      22: 'الحج',
      23: 'المؤمنون',
      24: 'النور',
      25: 'الفرقان',
      26: 'الشعراء',
      27: 'النمل',
      28: 'القصص',
      29: 'العنكبوت',
      30: 'الروم',
      31: 'لقمان',
      32: 'السجدة',
      33: 'الأحزاب',
      34: 'سبأ',
      35: 'فاطر',
      36: 'يس',
      37: 'الصافات',
      38: 'ص',
      39: 'الزمر',
      40: 'غافر',
      41: 'فصلت',
      42: 'الشورى',
      43: 'الزخرف',
      44: 'الدخان',
      45: 'الجاثية',
      46: 'الأحقاف',
      47: 'محمد',
      48: 'الفتح',
      49: 'الحجرات',
      50: 'ق',
      51: 'الذاريات',
      52: 'الطور',
      53: 'النجم',
      54: 'القمر',
      55: 'الرحمن',
      56: 'الواقعة',
      57: 'الحديد',
      58: 'المجادلة',
      59: 'الحشر',
      60: 'الممتحنة',
      61: 'الصف',
      62: 'الجمعة',
      63: 'المنافقون',
      64: 'التغابن',
      65: 'الطلاق',
      66: 'التحريم',
      67: 'الملك',
      68: 'القلم',
      69: 'الحاقة',
      70: 'المعارج',
      71: 'نوح',
      72: 'الجن',
      73: 'المزمل',
      74: 'المدثر',
      75: 'القيامة',
      76: 'الإنسان',
      77: 'المرسلات',
      78: 'النبأ',
      79: 'النازعات',
      80: 'عبس',
      81: 'التكوير',
      82: 'الانفطار',
      83: 'المطففين',
      84: 'الانشقاق',
      85: 'البروج',
      86: 'الطارق',
      87: 'الأعلى',
      88: 'الغاشية',
      89: 'الفجر',
      90: 'البلد',
      91: 'الشمس',
      92: 'الليل',
      93: 'الضحى',
      94: 'الشرح',
      95: 'التين',
      96: 'العلق',
      97: 'القدر',
      98: 'البينة',
      99: 'الزلزلة',
      100: 'العاديات',
      101: 'القارعة',
      102: 'التكاثر',
      103: 'العصر',
      104: 'الهمزة',
      105: 'الفيل',
      106: 'قريش',
      107: 'الماعون',
      108: 'الكوثر',
      109: 'الكافرون',
      110: 'النصر',
      111: 'المسد',
      112: 'الإخلاص',
      113: 'الفلق',
      114: 'الناس',
    };
    return surahs[surahNumber] ?? 'سورة $surahNumber';
  }

  Future<Duration?> getCurrentPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition();
    } catch (e) {
      _errorController.add('Failed to get current position: $e');
      return null;
    }
  }

  Future<Duration?> getDuration() async {
    try {
      return await _audioPlayer.getDuration();
    } catch (e) {
      _errorController.add('Failed to get duration: $e');
      return null;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _playbackStateController.close();
    _positionController.close();
    _durationController.close();
    _errorController.close();
  }
}
