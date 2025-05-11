import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/radio/data/radio_service.dart';
import '../../features/radio/domain/radio_model.dart';
import 'package:shimmer/shimmer.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  final RadioService _radioService = RadioService();
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
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadRadioStations();
    _initPrefs();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarkedUrls = _prefs.getStringList('bookmarked_stations') ?? [];
    setState(() {
      _bookmarkedStations =
          _stations
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
      _filteredStations =
          _stations.where((station) {
            return station.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playStation(String url, String name) async {
    try {
      if (_currentStation == url) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setSourceUrl(url);
        await _audioPlayer.resume();
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xff2F2F2F) : AppColors.primaryColor,
        title: const AppText(
          'الراديو',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'جميع المحطات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Tab(
              child: Text(
                'المحطات المفضلة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xff2F2F2F)
                        : AppColors.primaryColor,
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
                          _isPlaying
                              ? Icons.radio
                              : Icons.radio_button_unchecked,
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
                          await _audioPlayer.stop();
                          setState(() {
                            _currentStation = '';
                            _currentStationName = '';
                          });
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
                  color:
                      isDarkMode ? const Color(0xff2F2F2F) : Colors.grey[100],
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStationList(
                    _filteredStations.isEmpty ? _stations : _filteredStations,
                  ),
                  _buildStationList(_bookmarkedStations),
                ],
              ),
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

  Widget _buildStationList(List<RadioStation> stations) {
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

    return ListView.builder(
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
            border:
                isSelected
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
                color:
                    isDarkMode
                        ? Colors.grey[800]
                        : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.radio,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
            ),
            title: Text(
              station.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                fontFamily: 'Cairo',
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isDarkMode ? Colors.white : AppColors.primaryColor,
                  ),
                  onPressed: () => _toggleBookmark(station),
                ),
                IconButton(
                  icon: Icon(
                    isSelected && _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isDarkMode ? Colors.white : AppColors.primaryColor,
                  ),
                  onPressed: () => _playStation(station.url, station.name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
