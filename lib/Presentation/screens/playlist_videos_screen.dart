import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/models/playlist_model.dart';
import '../../domain/models/video_model.dart';
import '../../domain/services/youtube_service.dart';
import '../../domain/services/logging_service.dart';

class PlaylistVideosScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistVideosScreen({Key? key, required this.playlist})
      : super(key: key);

  @override
  State<PlaylistVideosScreen> createState() => _PlaylistVideosScreenState();
}

class _PlaylistVideosScreenState extends State<PlaylistVideosScreen> {
  final YoutubeService _youtubeService = YoutubeService();
  final String _tag = 'PlaylistVideosScreen';
  bool _isLoading = true;
  String? _error;
  List<VideoModel> _videos = [];
  YoutubePlayerController? _currentController;
  bool _isPlayerVisible = false;
  String? _currentVideoId;

  @override
  void initState() {
    super.initState();
    _loadPlaylistVideos();
  }

  @override
  void dispose() {
    _currentController?.close();
    super.dispose();
  }

  Future<void> _loadPlaylistVideos() async {
    try {
      LoggingService.info('Loading playlist videos', tag: _tag);
      final videos =
          await _youtubeService.getPlaylistVideos(widget.playlist.playlistId);
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading playlist videos',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _playVideo(VideoModel video) {
    LoggingService.info('Playing video: ${video.id}', tag: _tag);
    try {
      setState(() {
        _currentController?.close();
        _currentController = YoutubePlayerController.fromVideoId(
          videoId: video.id,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            playsInline: true,
            showVideoAnnotations: false,
            enableJavaScript: true,
          ),
        );
        _currentVideoId = video.id;
        _isPlayerVisible = true;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error initializing YouTube player',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error playing video. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _stopVideo() {
    setState(() {
      _currentController?.pauseVideo();
      _currentController?.close();
      _currentController = null;
      _currentVideoId = null;
      _isPlayerVisible = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isPlayerVisible) {
      _stopVideo();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.playlist.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isPlayerVisible) {
                _stopVideo();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlaylistVideos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text('No videos found in this playlist'),
      );
    }

    return Column(
      children: [
        if (_isPlayerVisible && _currentController != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: YoutubePlayerScaffold(
                controller: _currentController!,
                aspectRatio: 16 / 9,
                builder: (context, player) {
                  return player;
                },
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              final video = _videos[index];
              return _buildVideoCard(video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    final isPlaying = _currentVideoId == video.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _playVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'video_${video.id}',
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.error,
                          size: 40, color: Colors.white),
                    ),
                  ),
                ),
                if (isPlaying)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'تشغيل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPlaying
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
