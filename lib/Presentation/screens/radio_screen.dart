import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/radio/data/radio_service.dart';
import '../../features/radio/domain/radio_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/notification_service.dart';
import 'package:audio_session/audio_session.dart' as audio_session;
import '../Widgets/radio/radio_player_sheet.dart';
import '../Widgets/radio/radio_mini_player.dart';

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
  RadioStation? _currentStation;
  double _volume = 1.0;
  
  List<RadioStation> _stations = [];
  List<RadioStation> _filteredStations = [];
  List<RadioStation> _bookmarkedStations = [];
  
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
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
    if (_stations.isEmpty) return;
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
        if (state != PlayerState.playing) {
          _notificationService.removeNotification();
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      if (_isPlaying) {
        _audioPlayer.pause();
        _notificationService.removeNotification();
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
        _loadBookmarks();
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
      if (_currentStation != null) {
        _playStation(_currentStation!);
      }
    };
    _notificationService.onStop = _stopPlayback;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playStation(RadioStation station) async {
    try {
      if (_currentStation?.url == station.url) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          await _notificationService.removeNotification();
        } else {
          await _audioPlayer.resume();
          await _notificationService.showRadioNotification(
            stationName: station.name,
            isPlaying: true,
          );
        }
      } else {
        if (_currentStation != null) {
          await _audioPlayer.stop();
        }

        await _audioPlayer.setSourceUrl(station.url);
        await _audioPlayer.resume();
        await _notificationService.showRadioNotification(
          stationName: station.name,
          isPlaying: true,
        );
        setState(() {
          _currentStation = station;
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
    await _audioPlayer.stop();
    await _notificationService.removeNotification();
    setState(() {
      _isPlaying = false;
      _currentStation = null;
    });
  }

  void _showFullPlayer() {
    if (_currentStation == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return RadioPlayerSheet(
            station: _currentStation!,
            isPlaying: _isPlaying,
            volume: _volume,
            isBookmarked: _bookmarkedStations.any((s) => s.url == _currentStation!.url),
            onToggleBookmark: () async {
              await _toggleBookmark(_currentStation!);
              setSheetState(() {});
            },
            onPlayPause: () {
              _playStation(_currentStation!);
              setSheetState(() {});
            },
            onStop: () {
              _stopPlayback();
              Navigator.pop(context);
            },
            onVolumeChanged: (val) {
              setSheetState(() => _volume = val);
              _audioPlayer.setVolume(val);
            },
            onNext: () {
              _playNext();
              setSheetState(() {});
            },
            onPrevious: () {
              _playPrevious();
              setSheetState(() {});
            },
            onClose: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  void _playNext() {
    final list = _tabController.index == 0 ? _stations : _bookmarkedStations;
    if (list.isEmpty || _currentStation == null) return;
    
    int index = list.indexWhere((s) => s.url == _currentStation!.url);
    if (index != -1) {
      int nextIndex = (index + 1) % list.length;
      _playStation(list[nextIndex]);
    }
  }

  void _playPrevious() {
    final list = _tabController.index == 0 ? _stations : _bookmarkedStations;
    if (list.isEmpty || _currentStation == null) return;
    
    int index = list.indexWhere((s) => s.url == _currentStation!.url);
    if (index != -1) {
      int prevIndex = (index - 1 + list.length) % list.length;
      _playStation(list[prevIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(isDarkMode),
              _buildSearchAndTabs(isDarkMode),
              _buildStationsList(isDarkMode),
              if (_currentStation != null)
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          
          // Mini Player
          if (_currentStation != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              left: 0,
              right: 0,
              child: RadioMiniPlayer(
                station: _currentStation!,
                isPlaying: _isPlaying,
                onTap: _showFullPlayer,
                onPlayPause: () => _playStation(_currentStation!),
                onStop: _stopPlayback,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    final primaryColor = isDarkMode ? const Color(0xff1A2B25) : AppColors.primaryColor;
    
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const AppText(
          'الراديو الإسلامي',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode 
                    ? [const Color(0xff1A2B25), const Color(0xff121212)]
                    : [AppColors.primaryColor, const Color(0xff138A70)],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.radio,
                size: 180,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchAndTabs(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStations,
                decoration: InputDecoration(
                  hintText: 'ابحث عن محطة...',
                  prefixIcon: Icon(Icons.search_rounded, color: isDarkMode ? Colors.white60 : Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff1E1E1E) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDarkMode ? const Color(0xff4CAF93) : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.grey[600],
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'كل المحطات'),
                  Tab(text: 'المفضلة'),
                ],
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsList(bool isDarkMode) {
    if (_isLoading) {
      return SliverToBoxAdapter(child: _buildSkeletonLoading(isDarkMode));
    }

    if (_error != null) {
      return SliverFillRemaining(child: _buildErrorView());
    }

    final stations = _tabController.index == 0 
        ? (_searchController.text.isEmpty ? _stations : _filteredStations)
        : _bookmarkedStations;

    if (stations.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              AppText(_tabController.index == 0 ? 'لا توجد محطات' : 'لا توجد محطات مفضلة', color: Colors.grey),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final station = stations[index];
            final isSelected = _currentStation?.url == station.url;
            final isBookmarked = _bookmarkedStations.any((s) => s.url == station.url);
            
            return _StationCard(
              station: station,
              isSelected: isSelected,
              isPlaying: isSelected && _isPlaying,
              isBookmarked: isBookmarked,
              isDarkMode: isDarkMode,
              onTap: () => _playStation(station),
              onBookmark: () => _toggleBookmark(station),
            );
          },
          childCount: stations.length,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          AppText(_error!, color: Colors.red),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadRadioStations,
            child: const AppText('إعادة المحاولة', color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final RadioStation station;
  final bool isSelected;
  final bool isPlaying;
  final bool isBookmarked;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _StationCard({
    required this.station,
    required this.isSelected,
    required this.isPlaying,
    required this.isBookmarked,
    required this.isDarkMode,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDarkMode ? const Color(0xff4CAF93) : AppColors.primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? primaryColor.withValues(alpha: 0.2) 
                : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isSelected ? Colors.white : primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    station.name,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    align: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  // Handled by parent or specific button?
                  // Better explicitly handle bookmark here to avoid double tap
                  onBookmark();
                },
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isBookmarked ? primaryColor : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onBookmark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
