import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/playlist_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/services/playlist_cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class QasasScreen extends StatefulWidget {
  const QasasScreen({super.key});

  @override
  State<QasasScreen> createState() => _QasasScreenState();
}

class _QasasScreenState extends State<QasasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PlaylistCacheService _cacheService = PlaylistCacheService();
  bool _isLoading = true;
  bool _isOffline = false;
  List<PlaylistModel> _playlists = [];

  final List<PlaylistModel> _defaultPlaylists = [
    PlaylistModel(
      title: 'قصص الأنبياء',
      playlistId: 'PLv7XuvsLjBzYcEE0xuprcF6GwzY1JFXOV',
      thumbnailUrl: 'https://img.youtube.com/vi/hV42DbzZzx4/maxresdefault.jpg',
    ),
    PlaylistModel(
      title: 'قصص القرآن',
      playlistId: 'PLJ0WU3XQoz4-x5FPOHh3s8nRkeal-4ED7',
      thumbnailUrl: 'https://img.youtube.com/vi/rfbd68nNSI4/maxresdefault.jpg',
    ),
    PlaylistModel(
      title: 'قصص الصحابة',
      playlistId: 'PLJ0WU3XQoz4_vDPS0Xlaf3E2LgUz7pJsp',
      thumbnailUrl: 'https://img.youtube.com/vi/8aO-jm-3Oc0/maxresdefault.jpg',
    ),
    PlaylistModel(
      title: 'قصص التابعين',
      playlistId: 'PLJ0WU3XQoz49XWayvM7-m1N5ZgNNHL7fK',
      thumbnailUrl: 'https://img.youtube.com/vi/SMdRK8KVCT8/maxresdefault.jpg',
    ),
    PlaylistModel(
      title: 'قصص إسلامية',
      playlistId: 'PLJ0WU3XQoz4-4AjkrKBJTClcJxJsVF7RU',
      thumbnailUrl: 'https://img.youtube.com/vi/wHrxioBnB9o/maxresdefault.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => _isLoading = true);

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;

    if (isConnected) {
      // Online: Use default playlists and cache them
      _playlists = _defaultPlaylists;
      await _cacheService.cachePlaylists(_playlists);
      setState(() => _isOffline = false);
    } else {
      // Offline: Try to load from cache
      final cachedPlaylists = await _cacheService.getCachedPlaylists();
      if (cachedPlaylists.isNotEmpty) {
        _playlists = cachedPlaylists;
        setState(() => _isOffline = true);
      } else {
        // No cache available, use default playlists
        _playlists = _defaultPlaylists;
      }
    }

    setState(() => _isLoading = false);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchPlaylist(String playlistId) async {
    final Uri url =
        Uri.parse('https://www.youtube.com/playlist?list=$playlistId');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch playlist'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPlaylistCard(PlaylistModel playlist, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _launchPlaylist(playlist.playlistId),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: playlist.thumbnailUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 200,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          playlist.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'مشاهدة القائمة',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قصص',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_off, color: Colors.grey),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  return _buildPlaylistCard(_playlists[index], index);
                },
              ),
      ),
    );
  }
}
