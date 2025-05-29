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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _playVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
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
                    child: const Icon(Icons.error),
                  ),
                ),
                if (isPlaying)
                  Container(
                    height: 200,
                    color: Colors.black.withOpacity(0.3),
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
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? Theme.of(context).primaryColor : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        video.channelTitle,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(video.publishedAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.white,
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
