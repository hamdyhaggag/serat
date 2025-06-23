import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/radio/data/radio_service.dart';
import '../../features/radio/domain/radio_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/notification_service.dart';
import 'package:audio_session/audio_session.dart' as audio_session;

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  final RadioService _radioService = RadioService();
  final NotificationService _notificationService = NotificationService();
  bool _isPlaying = false;
  String _currentStation = '';
  String _currentStationName = '';
  double _volume = 1.0;
  List<RadioStation> _stations = [];
  List<RadioStation> _filteredStations = [];
  List<RadioStation> _bookmarkedStations = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadRadioStations();
    _initPrefs();
    _initNotificationService();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarkedUrls = _prefs.getStringList('bookmarked_stations') ?? [];
    setState(() {
      _bookmarkedStations = _stations
          .where((station) => bookmarkedUrls.contains(station.url))
          .toList();
    });
  }

  Future<void> _toggleBookmark(RadioStation station) async {
    final bookmarkedUrls = _prefs.getStringList('bookmarked_stations') ?? [];
    if (bookmarkedUrls.contains(station.url)) {
      bookmarkedUrls.remove(station.url);
    } else {
      bookmarkedUrls.add(station.url);
    }
    await _prefs.setStringList('bookmarked_stations', bookmarkedUrls);
    await _loadBookmarks();
  }

  void _filterStations(String query) {
    setState(() {
      _filteredStations = _stations.where((station) {
        return station.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Configure for background playback
    final session = await audio_session.AudioSession.instance;
    await session.configure(const audio_session.AudioSessionConfiguration(
      avAudioSessionCategory: audio_session.AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          audio_session.AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: audio_session.AVAudioSessionMode.defaultMode,
      androidAudioAttributes: audio_session.AndroidAudioAttributes(
        contentType: audio_session.AndroidAudioContentType.music,
        flags: audio_session.AndroidAudioFlags.none,
        usage: audio_session.AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: audio_session.AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen for audio session interruptions
    session.becomingNoisyEventStream.listen((_) {
      if (_isPlaying) {
        _playStation(_currentStation, _currentStationName);
      }
    });
  }

  Future<void> _loadRadioStations() async {
    try {
      final stations = await _radioService.getRadioStations();
      if (mounted) {
        setState(() {
          _stations = stations;
          _filteredStations = stations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initNotificationService() async {
    await _notificationService.initialize();
    _notificationService.onPlayPause = () {
      if (_currentStation.isNotEmpty) {
        _playStation(_currentStation, _currentStationName);
      }
    };
    _notificationService.onStop = _stopPlayback;
  }

  @override
  void dispose() {
    // Only dispose if we're not playing
    if (!_isPlaying) {
      _audioPlayer.dispose();
    }
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playStation(String url, String name) async {
    try {
      if (_currentStation == url) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          await _notificationService.showRadioNotification(
            stationName: name,
            isPlaying: false,
          );
        } else {
          await _audioPlayer.resume();
          await _notificationService.showRadioNotification(
            stationName: name,
            isPlaying: true,
          );
        }
      } else {
        // Stop current playback if any
        if (_currentStation.isNotEmpty) {
          await _audioPlayer.stop();
        }

        // Set new source and start playback
        await _audioPlayer.setSourceUrl(url);
        await _audioPlayer.resume();
        await _notificationService.showRadioNotification(
          stationName: name,
          isPlaying: true,
        );
        setState(() {
          _currentStation = url;
          _currentStationName = name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تشغيل المحطة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopPlayback() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      await _notificationService.removeNotification();
      setState(() {
        _isPlaying = false;
        _currentStation = '';
        _currentStationName = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(
        title: 'الراديو',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildUnifiedLayout(_tabController.index == 0
                  ? (_filteredStations.isEmpty ? _stations : _filteredStations)
                  : _bookmarkedStations),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
        iconSize: 32,
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnifiedLayout(List<RadioStation> stations) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadRadioStations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? const Color(0xff2F2F2F) : AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isPlaying)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.2),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      Icon(
                        _isPlaying ? Icons.radio : Icons.radio_button_unchecked,
                        size: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppText(
                  _currentStation.isEmpty ? 'اختر محطة' : _currentStationName,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: () {
                        if (_currentStation.isNotEmpty) {
                          _playStation(_currentStation, _currentStationName);
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildControlButton(
                      icon: Icons.stop,
                      onPressed: () async {
                        await _stopPlayback();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_down, color: Colors.white),
                      Expanded(
                        child: Slider(
                          value: _volume,
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                            });
                            _audioPlayer.setVolume(value);
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff2F2F2F) : Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStations,
                onTap: () {
                  // Scroll to top when search field is tapped
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن محطة...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      isDarkMode ? const Color(0xff2F2F2F) : Colors.grey[100],
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff2F2F2F) : Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDarkMode ? Colors.white60 : Colors.grey[600],
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radio,
                          size: 18,
                          color: _tabController.index == 0
                              ? Colors.white
                              : (isDarkMode
                                  ? Colors.white60
                                  : Colors.grey[600]),
                        ),
                        const SizedBox(width: 6),
                        const Text('كل المحطات'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 18,
                          color: _tabController.index == 1
                              ? Colors.white
                              : (isDarkMode
                                  ? Colors.white60
                                  : Colors.grey[600]),
                        ),
                        const SizedBox(width: 6),
                        const Text('المفضلة'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_tabController.index == 1 && _bookmarkedStations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border,
                      size: 60,
                      color: isDarkMode ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'لا توجد محطات مفضلة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'اضغط على أيقونة المفضلة لإضافة محطات إلى قائمة المفضلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white60 : Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    icon: const Icon(Icons.radio),
                    label: const Text('استكشف المحطات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                final isSelected = station.url == _currentStation;
                final isBookmarked = _bookmarkedStations.any(
                  (s) => s.url == station.url,
                );

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(color: AppColors.primaryColor, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]
                            : AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.radio,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                    title: Text(
                      station.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                          onPressed: () => _toggleBookmark(station),
                        ),
                        IconButton(
                          icon: Icon(
                            isSelected && _isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                          onPressed: () =>
                              _playStation(station.url, station.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
